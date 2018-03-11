## Gimp custom theme

The below README.md comes from the theme I currently use for gimp. I didn't
include the whole thing here because it's 80MB.

---


The Flat Themes were created by Android272 and can be found at http://android272.deviantart.com/

special thanks to knozos maker of the DPixel theme on DA for help with theme,  ZZDas maker of the minimo on DA for small theme text, Eckhard M. Jäger maker of the ProGimp theme for colored icons, doctormo maker of PsIcons them on DA for getting rid of tool box lable and help with gtkrc, and Mirek2's flat icon concept from LibreOffice.

# Change Log
# =========================================================

Last modified
11-20-2014
   * Created "Experimental" version for test perpuses.
   * Fixed stock-image, stock-selection, stock-default-colors icons
   * Documentation changes
11-16-2014
   * I have completely rewrote these 8 themes. 
   * You now will get along with the 8 icon themes a folder called "Decor". This folder needs to be placed in your Themes directory in-order for V2 and on to work.  Icons and gtk.rc files have been moved there to conserve data for you. 
   *All the icons are now located in a icons folder in the "Decor" folder and all themes link to it instead of having their own set of icons.
3/18/2014
   * added gradiented icons
   * added Darker, Dark, Light, Liter and their small themes
   * added menu icons
11/26/2013
   * bug fixes
4/29s/2013
   * Dark set complete
   * Dark Tool icons
   * Dark Dialog icons
   * Dark General icons
3/9/2013
   * Light set complete
   * Light General icons
2/15/2013
   * Light Dialog icons
2/2/2013
   * Light Tool icons

The purpose of this theme was to completely change out every GIMP icon and make it beautiful.
This theme was made as a GIMP only theme but I'm sure that you can modify it to suit other 
GTK+ programs. My hope is that designers/enthusiasts might use my theme as a template for 
new themes to come. I am not a icon designer which I think is evident in my work. I tried 
to keep the same standards through out the theme but as you can see that did not always happen. 

Colored icons

If you do not like the colored icons for selected tools and when hovering over them then you can replace them. in the tools directory there are two folders, one for colored icons and the other for that themes icons. copy and replace these icons into the tools folder and everything should go back to the way it was when this theme was first released.

# Instillation
# =========================================================

# Linux
Copy the Theme you want and the Decor folder into ~gimp-2.8/themes

# Mac
Copy the Theme you want and the Decor folder into Aplications > Right Click Gimp and select Show Package Contents > Contents > Resources > Share > gimp > 2.0 > themes

# Windows
Copy the Theme you want and the Decor folder into C:\Documents and Settings\{YourUsername}\.gimp-2.4\palettes or C:\Program Files\GIMP 2\share\gimp\2.0\themes\ or C:\Program Files (x86)\GIMP 2\share\gimp\2.0\themes\



Once this is done open GIMP and goto edit > preferences > themes > choose the theme you like best.

# LICENSE
# =========================================================

This theme is licensed under both the GNU GENERAL PUBLIC LICENSE(GPL) and the CREATIVE COMMONS 
LICENSE. This means that you may take this theme and do with it as you will.  Distribute it,
 modify it, redistribute it as long as every one you redistribute it to is given these same
rights.

# Modification
# =========================================================

The "gtkrc" file is what controls the theme color scheme. I tried to comment it the best I could
so that you might know what every hex color did.  Just play around with everything until you know
what things do. The "imagerc" file is what changes out all the icons out. Like the ProGIMP theme
I made it so that when you hover over and select tools and even Dialog tabs the icons change.  My
theme just does not take advantage of this as it looked weird. All you should have to do is modify 
the icons while keeping the same names.  It is important that you do not change the names of any 
icons and even more importantly not to change the style name and stock id variables in the 
"imagerc" as this will mess the whole theme up. Note if you use a different file format for your 
icons you will have to change every file location in the "imagerc" file.  This is just a simple 
ctrl+H find all ".svg" and replace them with ".png" for example.  Also if you do not want your 
theme to change like the ProGIMP theme then either do like I did and make the normal icon and 
the colored icon the same with different names or delete the code where it changes the icons.
