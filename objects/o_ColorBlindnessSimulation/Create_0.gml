/// @description  Setup Simulation Shaders 
{
    // Enumerate shaders
    modeShad[1] = xot_cbs_shDeuteranopia;
    modeText[1] = "Deuteranopia";
    modeShad[2] = xot_cbs_shProtanopia;
    modeText[2] = "Protanopia";
    modeShad[3] = xot_cbs_shTritanopia;
    modeText[3] = "Tritanopia";
	modeShad[4] = xot_cbs_shGrayscale;
    modeText[4] = "Grayscale";

    // Set shader state
    enabled = true;
    mode = global.colorblindsettings;
    modes = array_length_1d(modeShad);
}
if global.colorblindsettings = 0 { instance_destroy(o_ColorBlindnessSimulation) }

/// README.TXT
//
//  COLOR BLINDNESS SIMULATION SHADER
//
//  Thank you for trying this tool. I hope you find it informative
//  and that it helps make your projects more accessible. See USAGE.TXT
//  for details on how to incorporate this packing into your projects.
//
//  The code in this project is released under the GMLscripts.com
//  License. You are free to use it in any project. Please read
//  LICENSE.TXT for full details.
//
//  If you make use of this package for one of your projects, I'd love 
//  to hear about your experience. Do not hesitate to contact me if
//  you need any help or have any special requirements.
//
//  John Leffingwell, xot@gmlscripts.com
//
/// GMLscripts.com/license


/// USAGE.TXT
//
//  To use with your projects, only a few resources need to be
//  imported. They are the oColorBlindnessSimulation object and the
//  three shaders shDeuteranopia, shProtanopia, and shTritanopia.
//  The resources within "DEMO" groups are not needed.
//
//  The simulation is performed entirely by the shaders. By adding
//  the oColoBlindSimulation object to a room, you may easily enable
//  a simulation in your project. The object relies on the 
//  application surface to function in simplest possible way.
//
//  It is up the developer to invoke the simulation by a key press or
//  other means. It may be useful to enable the "Persistent" property
//  of oColorBlindnessSimulation to keep the object instance active
//  from room to room.
//
//  oColorBlindSimulation has the following properties/variables:
//
//      enabled         toggles display of simulation, bool 
//      mode            current shader, real
//      modes           number of shaders, real
//      modeShad[]      shader resource ids, array
//      modeText[]      shader descriptive names, array
//
//  Once active and enabled, during the Post Draw event a simulation
//  shader is set by the simulation object. After the Post Draw event, 
//  GameMaker: Studio will draw the application surface to the screen. 
//  Because a simulation shader is set, the application surface will be 
//  drawn using the simulation. After this, the Draw GUI events begin. 
//  They will also be drawn using the still-active simulation shader. 
//  Finally, during the Draw GUI End event, the simulation object will 
//  disable the simulation shader.
//
//  As long as you do not use shaders of your own during Draw GUI
//  events, everything should work seamlessly. If you do not have access
//  to the application surface, or otherwise need more control over when
//  a simulation shader is active, it is as easy as calling:
//
//      shader_set(shDeuteranopia)
//
//  ... to start the simulation whenever you need it.
//
/// GMLscripts.com/license


/// LICENSE.TXT
//
//  Copyright (c) 2007-2016, GMLscripts.com
//  
//  This software is provided 'as-is', without any express or implied 
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  
//  Permission is granted to anyone to use this software for any purpose, 
//  including commercial applications, and to alter it and redistribute it 
//  freely, subject to the following restrictions:
//  
//    1. The origin of this software must not be misrepresented; you must not
//       claim that you wrote the original software. If you use this software
//       in a product, an acknowledgment in the product documentation would be
//       appreciated but is not required.
//  
//    2. Altered source versions must be plainly marked as such, and must not be
//       misrepresented as being the original software.
//  
//    3. This notice may not be removed or altered from any source distribution.
//    
/// GMLscripts.com/license

/// MOREINFO.TXT
//
//  Here are some links to online articles covering various aspects
//  color perception, accessibility, and design considerations.
//  
//
//  WIKIPEDIA
//
//  Color Blindness
//      http://en.wikipedia.org/wiki/Color_blindness
//
//
//
//  ACCESSIBILITY IN GAMES
//
//  Game Accessibility Guidelines
//      http://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-colour-alone
//
//  Color Blindness in Gaming
//      http://www.gamasutra.com/blogs/BrandonKidwell/20140806/222519/GDotD__COLOR_BLINDNESS_IN_GAMING
//
//  Red vs. Green: Gaming with Colour Blindness
//      http://www.ign.com/articles/2014/07/14/50-shades-of-game-gaming-with-colour-blindness
//
//  What It's Like To Play Games When You're Colorblind
//      http://kotaku.com/what-its-like-to-play-games-when-youre-colorblind-1606030489
//
//
//
//  DESIGN
//
//  Designing Maps for the Colour-Vision Impaired 
//      http://www.colororacle.org/resources/2007_JennyKelso_DesigningMapsForTheColourVisionImpaired.pdf
//
//  Color Design for the Color Vision Impaired
//      http://www.colororacle.org/resources/2007_JennyKelso_ColorDesign_lores.pdf
//
//  Color Brewer
//      http://colorbrewer2.org/
//
//
//
//  TOOLS
//
//  Vischeck
//      http://www.vischeck.com/
//
//  Color Oracle
//      http://www.colororacle.org/index.html
//
//  Online Color Test Challenge
//      http://www.xrite.com/online-color-test-challenge
//
//  Colblindor
//      http://www.color-blindness.com/
//
///


