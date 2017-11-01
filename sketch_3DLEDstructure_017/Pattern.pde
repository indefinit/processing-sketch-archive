/**
* Pattern Manager
* @author Gabe Liberti, Kevin Siwoff
* @version 1.1
* @date 1-27-15
* @description Generic pattern class for handling color palette and gradient processing.
* Class is intentionally setup to hold only 1 color palette per pattern.
* Best practice is to subclass Pattern and create custom patterns there.
*/

import colorLib.calculation.*;
import colorLib.*;
import colorLib.webServices.*;

class Pattern {
	private Palette palette;// our ColorLib Palette
	PApplet parent; //important to pass in reference to PApplet otherwise functions won't work
	Pattern(){
		palette = new Palette(parent);
	} 

	/**
	 * sets an arbitrary number of colors as our palette
	 * @param {int[] | color[]} color[] cols collection of colors
	 */
	void setPaletteColors(color[] cols){
		for (color col : cols) {
				palette.addColor(col);		
		}
	}

	/**
	 * creates a new gradient from a given palette. after calling this method
	 * you can access specific cols along the gradient like gradient.getColor(i),
	 * where gradient is a local variable and i is a step index.
	 * @param  {Palette} p             palette
	 * @param  {int}     steps         steps in gradient
	 * @param  {boolean} wrap          does the gradient wrap around?
	 * @return {Gradient}         		 Gradient obj
	 */
	public Gradient makeGradient(Palette p, int steps, boolean wrap){
		return new Gradient(p, steps, wrap);
	}

	/**
	 * convenience function for returning ColorLib palette
	 * @return {Palette} a collection of colors
	 */
	public Palette getColorPalette(){
		return palette;
	}
}//END PATTERN CLASS
