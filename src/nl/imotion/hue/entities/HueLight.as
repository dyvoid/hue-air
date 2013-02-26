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

package nl.imotion.hue.entities
{
    import flash.geom.Point;

    import nl.imotion.hue.enums.Alert;


    /**
     * @author Pieter van de Sluis
     */
    public class HueLight extends HueEntity
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _alert          :String;

        private var _reachable      :Boolean;

        private var _type           :String;
        private var _modelID        :String;
        private var _swVersion      :String;
        private var _pointSymbol    :Object;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueLight( id:String, propsObject:Object = null )
        {
            super( id );

            if ( propsObject )
            {
                fromObject( propsObject );
            }
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function fromObject( propsObject:Object ):void
        {
            try
            {
                basePropsFromObject( propsObject.state );
                _alert = propsObject.state.alert;
                _reachable = propsObject.state.reachable;
                _type = propsObject.type;
                name = propsObject.name;
                _modelID = propsObject.modelid;
                _swVersion = propsObject.swversion;
                _pointSymbol = propsObject.pointsymbol;

                isInvalid = false;
            }
            catch ( e:Error )
            {
                throw new Error( "Properties object is invalid" );
            }
        }


        override public function toStateObject():Object
        {
            var obj:Object = super.toStateObject();
            obj.alert = _alert;

            return obj;
        }


        public function alert( isLongSelect:Boolean = false ):void
        {
            _alert = isLongSelect ? Alert.LONG_SELECT : Alert.SELECT;
            isInvalid = true;
        }

        // ____________________________________________________________________________________________________
        // PRIVATE


        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        public function get alertState():String
        {
            return _alert;
        }


        public function get reachable():Boolean
        {
            return _reachable;
        }


        public function get type():String
        {
            return _type;
        }


        public function get modelID():String
        {
            return _modelID;
        }


        public function get swVersion():String
        {
            return _swVersion;
        }


        public function get pointSymbol():Object
        {
            return _pointSymbol;
        }


        override public function set isInvalid( value:Boolean ):void
        {
            super.isInvalid = value;

            // Reset alert state, otherwise we will send it with every invalidation
            if ( !value )
            {
                _alert = Alert.NONE;
            }
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}