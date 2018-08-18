# gib theme

%sh{
    # First we define the gib colors as named colors
    gib_darker_grey="rgb:303030"
    gib_black="rgb:000000"
    gib_dark_grey="rgb:444444"
    gib_grey="rgb:808080"
    gib_light_grey="rgb:b2b2b2"
    gib_lighter_grey="rgb:d7d7d7"

    gib_dark_red="rgb:870000"
    gib_light_red="rgb:ff8787"
    gib_orange="rgb:d78700"
    gib_purple="rgb:d7afd7"

    gib_dark_green="rgb:5f875f"
    gib_bright_green="rgb:87af00"
    gib_green="rgb:afd787"
    gib_light_green="rgb:d7d7af"

    gib_dark_blue="rgb:005f87"
    gib_blue="rgb:87afd7"
    gib_light_blue="rgb:87d7ff"

    gib_bright_green="rgb:6bf549"

    echo "
        # then we map them to code
        face global value ${gib_light_green}
        face global type ${gib_blue}
        face global variable ${gib_green}
        face global module ${gib_green}
        face global function ${gib_light_blue}
        face global string ${gib_light_green}
        face global keyword ${gib_light_blue}
        face global operator ${gib_green}
        face global attribute ${gib_light_blue}
        face global comment ${gib_grey}+i
        face global meta ${gib_purple}
        face global builtin default+b

        # and markup
        face global title ${gib_light_blue}
        face global header ${gib_light_green}
        face global bold ${gib_blue}
        face global italic ${gib_green}
        face global mono ${gib_light_green}
        face global block ${gib_light_blue}
        face global link ${gib_light_green}
        face global bullet ${gib_green}
        face global list ${gib_blue}

        # and built in faces
        face global Default ${gib_light_grey},${gib_black}
        face global PrimarySelection ${gib_darker_grey},${gib_orange}
        face global SecondarySelection  ${gib_lighter_grey},${gib_dark_blue}
        face global PrimaryCursor ${gib_darker_grey},${gib_bright_green}
        face global SecondaryCursor ${gib_darker_grey},${gib_lighter_grey}
        face global PrimaryCursorEol ${gib_darker_grey},${gib_dark_green}
        face global SecondaryCursorEol ${gib_darker_grey},${gib_dark_green}
        face global LineNumbers ${gib_grey},${gib_dark_grey}
        face global LineNumberCursor ${gib_grey},${gib_dark_grey}+b
        face global MenuForeground ${gib_blue},${gib_dark_blue}
        face global MenuBackground ${gib_darker_grey},${gib_light_grey}
        face global MenuInfo ${gib_grey}
        face global Information ${gib_lighter_grey},${gib_dark_green}
        face global Error ${gib_light_red},${gib_dark_red}
        face global StatusLine ${gib_lighter_grey},${gib_dark_grey}
        face global StatusLineMode ${gib_lighter_grey},${gib_dark_green}+b
        face global StatusLineInfo ${gib_dark_grey},${gib_lighter_grey}
        face global StatusLineValue ${gib_lighter_grey}
        face global StatusCursor default,${gib_blue}
        face global Prompt ${gib_lighter_grey}
        face global MatchingChar ${gib_lighter_grey},${gib_bright_green}
        face global BufferPadding ${gib_green},${gib_darker_grey}
    "
}
