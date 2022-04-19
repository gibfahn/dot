" {{{ Functions

function! s:CallRipGrep(...) abort
  call fzf#vim#grep('rg --vimgrep --color=always --smart-case --hidden --glob !.git -F ' . shellescape(join(a:000, ' ')), 1,
        \ fzf#vim#with_preview({ 'options': ['-m', '--bind=ctrl-a:toggle-all,alt-j:jump,alt-k:jump-accept']}, 'right:50%', 'ctrl-p'), 1)
endfunction

function! s:RipWithRange() range
  call s:CallRipGrep(join(getline(a:firstline, a:lastline), '\n'))
endfunction
call operator#user#define('ripgrep-root', 'OperatorRip')

function! OperatorRip(wiseness) abort
  if a:wiseness ==# 'char'
    normal! `[v`]"ay
    call s:CallRipGrep(@a)
  elseif a:wiseness ==# 'line'
    '[,']call s:RipWithRange()
  endif
endfunction

" Open path or URL using system open command.
function! Browse(pathOrUrl)
  " This doesn't work with /usr/bin/vim on macOS (doesn't identify as macOS).
  if has('mac')| let openCmd = 'open'| else| let openCmd = 'xdg-open'| endif
    silent execute "! " . openCmd . " " . shellescape(a:pathOrUrl, 1)| " Escape Path or URL and pass as arg to open command.
    echo openCmd . " " shellescape(a:pathOrUrl, 1)| " Echo what we ran so it's visible.
endfunction

" Opens current buffer in previous split (at the same position but centered).
function! DupBuffer()
  let pos = getpos(".") " Save cursor position.
  let buff = bufnr('%') " Save buffer number of current buffer.
  execute "normal! \<c-w>p:b " buff "\<CR>"| " Change to previous buffer and open saved buffer.
  call setpos('.', pos) " Set cursor position to what is was before.
endfunction

" Make vim-surround work in operator-pending mode, so the cursor changes when you press e.g. ys.
" Requires custom mapping and disabling default mappings (SurroundOp).
function! SurroundOp(char)
    if v:operator ==# 'd'
        return "\<plug>D" . a:char . "urround"
    elseif v:operator ==# 'c'
        return "\<plug>C" . a:char . "urround"
    elseif v:operator ==# 'y'
        return "\<plug>Y" . a:char . "urround"
    endif
    return ''
endfunction

" Returns the function the cursor is currently in, used in lightline status bar.
function! CocCurrentFunction()
  let f = get(b:, 'coc_current_function', '')
  return f == '' ? '' : f . '()'
endfunction

" Function to trim trailing whitespace in a file.
function! TrimWhitespace()
  let l:save = winsaveview()
  %s/\s\+$//e
  call winrestview(l:save)
endfunction

" Function to sort lines as an operator.
function! SortLinesOpFunc(...)
    '[,']sort
endfunction

 " Helper function for LightlineCoc*() functions.
function! s:lightline_coc_diagnostic(kind, sign) abort
  let info = get(b:, 'coc_diagnostic_info', 0)
  if empty(info) || get(info, a:kind, 0) == 0
    return ''
  endif
  return printf("%s %d", a:sign, info[a:kind])
endfunction

" Used in LightLine config to show diagnostic messages.
function! LightlineCocErrors() abort
  return s:lightline_coc_diagnostic('error', '✖')
endfunction
function! LightlineCocWarnings() abort
    return s:lightline_coc_diagnostic('warning', "⚠")
endfunction
function! LightlineCocInfos() abort
  return s:lightline_coc_diagnostic('information', "ℹ")
endfunction
function! LightlineCocHints() abort
  return s:lightline_coc_diagnostic('hints', "ℹ")
endfunction

" Sums the selected numbers.
function! SumVis()
    try
        let l:a_save = @a
        norm! gv"ay
        let @a = substitute(@a,'[^0-9. ]','+','g')
        exec "norm! '>o"
        exec "norm! iTotal \<c-r>=\<c-r>a\<cr>"
     finally
        let @a = l:a_save
     endtry
endfun

" See https://github.com/jonhoo/proximity-sort , makes closer paths to cwd higher priority.
function! s:list_cmd(kind, query)
  if a:kind == 'find'
    let base = fnamemodify(expand('%'), ':h:.:S')
    return base == '.' ? 'fd --hidden --type file --exclude=.git' : printf('fd --hidden --type file --exclude=.git | proximity-sort %s', expand('%'))
  elseif a:kind == 'locate'
    return 'locate -i ' . a:query . ' | proximity-sort ' . getcwd()
  endif
endfunction

" }}} Functions

" {{{ Commands

" Browse command is used by fugitive as I have Netrw disabled.
command! -nargs=1 Browse call Browse(<q-args>)|     " :Browse runs :call Browse() (defined above).
command! Trim call TrimWhitespace()|                " :Trim runs :call Trim() (defined above).
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!| " :W writes as sudo.

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, {'source': s:list_cmd('find', ''),
  \                               'options': '--tiebreak=index'}, <bang>0)

command! -bang -nargs=? -complete=dir Locate
  \ call fzf#vim#locate(<q-args>, {'source': s:list_cmd('locate', <q-args>),
  \                               'options': '--tiebreak=index'}, <bang>0)

" Use Rg to specify the string to search for (can be regex).
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg  --vimgrep --color=always --smart-case --hidden ' . shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'options': ['-m', '--bind=ctrl-a:toggle-all,alt-j:jump,alt-k:jump-accept']}, 'right:50%', 'ctrl-p'))

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Run a command and interpret the output in the quickfix window
command! -nargs=+ -complete=file Cr cexpr system(<q-args>)
" Run a command and interpret the output in the location window
command! -nargs=+ -complete=file Lr lexpr system(<q-args>)

" }}} Commands

" {{{ Autocommands

augroup gibAutoGroup                                " Group of automatic functions.
  autocmd!|                                         " Remove existing autocmds.

  autocmd BufNewFile,BufRead *.bats  set filetype=sh       " Bats is a shell test file type.
  autocmd BufReadPost *|                            " On open jump to last cursor position if possible.
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   execute "normal g`\"" |
    \ endif
  autocmd BufWritePost <sfile> nested source <sfile> " Reload vimrc on save.
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC " Reload vimrc on save.
  autocmd BufWritePre * if expand("<afile>:p:h") !~ "fugitive:" | call mkdir(expand("<afile>:p:h"), "p") | endif " Create dir if it doesn't already exist on save.
  autocmd FileType fugitive nmap <buffer> S sk]c| " https://github.com/tpope/vim-fugitive/issues/1926
  autocmd FileType fugitive nmap <buffer> <A-g> ]c| " Skip to next git hunk.
  autocmd FileType fugitive nmap <buffer> <A-G> [c| " Skip to previous git hunk.
  autocmd FileType go set listchars=tab:\ \ ,trail:·,nbsp:☠ " Don't highlight tabs in Go.
  autocmd FileType help wincmd L                    " Open new help windows on the right,
  autocmd FileType json setlocal foldmethod=indent  " JSON files should be folded by indent.
  " Allow comments in json.
  autocmd FileType json syntax match Comment +\/\/.\+$+
  autocmd FileType python setlocal foldmethod=indent textwidth=100  " Python files should be folded by indent.
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json,rust setl formatexpr=CocAction('formatSelected')
  autocmd FileType yaml setlocal foldmethod=indent  " YAML files should be folded by indent.
  " Check if files modified when you open a new window, switch back to vim, or if you don't move the cursor for 100ms.
  " Use getcmdwintype() to avoid running in the q: window (otherwise you get lots of errors).
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if getcmdwintype() == '' | checktime | endif
  autocmd QuickFixCmdPost *grep* cwindow|           " Open the quickfix window on grep.
  autocmd User CocDiagnosticChange call lightline#update()
  autocmd VimEnter * silent! tabonly|               " Don't allow starting Vim with multiple tabs.

  " :h lightspeed-custom-mappings
  autocmd User LightspeedSxEnter let g:lightspeed_last_motion = 'sx'
  autocmd User LightspeedFtEnter let g:lightspeed_last_motion = 'ft'

  au TermOpen * setlocal nonumber norelativenumber  " No line numbers in terminal
  au TermOpen * setlocal wrap                     " Soft line wrapping in terminal.
augroup END

" }}} Autocommands

" vim: foldmethod=marker
