﻿package {	import flash.display.*;	public class AnimationTest extends MovieClip {				public function AnimationTest() {			// create 50 objects at random locations with random speeds			for(var i:uint=0;i<50;i++) {				var a:AnimatedObject = new AnimatedObject(Math.random()*550,Math.random()*400,getRandomSpeed(),getRandomSpeed());				addChild(a);			}		}				// get a speed from 70-100, positive or negative		public function getRandomSpeed() {			var speed:Number = Math.random()*70+30;			if (Math.random() > .5) speed *= -1;			return speed;		}	}}