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
    import mx.formatters.DateFormatter;


    /**
     * @author Pieter van de Sluis
     */
    public class HueSchedule extends HueEntity
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        private var _time           :Date;
        private var _description    :String = "";

        private var _target         :HueEntity;
        private var _transitionTime :uint = 10;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueSchedule()
        {
            super( null );

            init();
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function toObject():Object
        {
            var operationName:String;

            switch ( true )
            {
                case _target is HueLight:
                    operationName = "/lights/" + _target.id + "/state";
                    break;

                case _target is HueGroup:
                    operationName = "/groups/" + _target.id + "/action";
                    break;
            }

            var obj:Object =
            {
                "name": name,
                "time": getTimeString(),
                "description": _description,
                "command":
                {
                    "method": "PUT",
                    "address": "/api/{userName}" + operationName,
                    "body": toStateObject()
                }
            };

            return obj;
        }


        override public function toStateObject():Object
        {
            var obj:Object = super.toStateObject();
            obj.transitiontime = _transitionTime;

            return obj;
        }


        private function getTimeString():String
        {
            var dateString:String =
                    _time.fullYearUTC + "-" +
                    leadingZero( _time.getUTCMonth() + 1 ) + "-" +
                    leadingZero( _time.getUTCDate() ) + "T" +
                    leadingZero( _time.getUTCHours() ) + ":" +
                    leadingZero( _time.getUTCMinutes() ) + ":" +
                    leadingZero( _time.getUTCSeconds() );

            return dateString;
        }


        private function leadingZero( value:uint ):String
        {
            if( value < 10 )
            {
                return "0" + value;
            }

            return value.toString();
        }

        // ____________________________________________________________________________________________________
        // PRIVATE

        private function init():void
        {
            _time = new Date();
            isOn = true;
        }

        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        [Bindable]
        public function get time():Date
        {
            return _time;
        }
        public function set time( value:Date ):void
        {
            _time = value;
        }

        [Bindable]
        public function get description():String
        {
            return _description;
        }
        public function set description( value:String ):void
        {
            _description = value;
        }

        [Bindable]
        public function get target():HueEntity
        {
            return _target;
        }
        public function set target( value:HueEntity ):void
        {
            _target = value;
        }

        [Bindable]
        public function get transitionTime():uint
        {
            return _transitionTime;
        }
        public function set transitionTime( value:uint ):void
        {
            _transitionTime = value;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}