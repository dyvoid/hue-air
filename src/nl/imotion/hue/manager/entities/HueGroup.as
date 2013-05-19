/*
 * Licensed under the MIT license
 *
 * Copyright (c) 2009-2013 Pieter van de Sluis
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * http://code.google.com/p/imotionproductions/
 */

package nl.imotion.hue.manager.entities
{
    import flash.utils.Dictionary;


    /**
     * @author Pieter van de Sluis
     */
    public class HueGroup extends HueEntity
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _lights:Vector.<HueLight>;
        private var _lightsDictionary:Dictionary;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueGroup( id:String, propsObject:Object = null )
        {
            super( id );

            _lights = new  Vector.<HueLight>();
            _lightsDictionary = new Dictionary();

            if ( propsObject )
            {
                fromObject( propsObject );
            }
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        override public function fromObject( propsObject:Object ):void
        {
            try
            {
                super.fromObject( propsObject );
                basePropsFromObject( propsObject.action );
            }
            catch ( e:Error )
            {
                throw new Error( HueEntity.ERROR_INVALID_OBJECT );
            }
        }


        public function addLight( light:HueLight ):void
        {
            _lights.push( light );
            _lightsDictionary[ light.id ] = light;
        }


        public function getLightByID( id:String ):HueLight
        {
            return _lightsDictionary[ id ];
        }

        // ____________________________________________________________________________________________________
        // PRIVATE


        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        public function get lights():Vector.<HueLight>
        {
            return _lights;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}