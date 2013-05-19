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

package nl.imotion.hue.ui.model
{
    import nl.imotion.bindmvc.model.BindModel;
    import nl.imotion.hue.manager.HueManager;
    import nl.imotion.hue.manager.entities.HueEntity;
    import nl.imotion.hue.manager.entities.HueGroup;
    import nl.imotion.hue.manager.entities.HueLight;
    import nl.imotion.hue.manager.entities.HueSchedule;
    import nl.imotion.hue.ui.notes.ModelReadyNote;
    import nl.imotion.hue.ui.vo.VOLogin;


    /**
     * @author Pieter van de Sluis
     */
    public class HueModel extends BindModel
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        public static const NAME:String = "nl.imotion.hue.ui.model.HueModel"

        private var _manager:HueManager;

        private var _isReady:Boolean = false;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function HueModel()
        {
            super( NAME );

            init();
        }


        private function init():void
        {
            _manager = new HueManager();
        }

        // ____________________________________________________________________________________________________
        // PUBLIC

        public function discoverBridge( onResult:Function, onFault:Function ):void
        {
            _manager.discoverBridge( onResult, onFault );
        }


        public function createUser( userName:String, deviceType:String, onResult:Function, onFault:Function ):void
        {
            _manager.createUser( userName, deviceType, onResult, onFault );
        }


        public function connect( loginData:VOLogin ):void
        {
            _manager.connect( loginData.ipAddress, loginData.userName, onConnectResult, null );
        }


        private function onConnectResult():void
        {
            dispatchNote( new ModelReadyNote( _manager.lightsMap, _manager.groupsMap, _manager.entityMap ) );
        }


        public function createSchedule( schedule:HueSchedule, onResult:Function, onFault:Function ):void
        {
            _manager.createSchedule( schedule, onResult, onFault );
        }

        // ____________________________________________________________________________________________________
        // PRIVATE



        // ____________________________________________________________________________________________________
        // PROTECTED



        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        public function get lightsMap():Vector.<HueLight>
        {
            return _manager.lightsMap;
        }


        public function get groupsMap():Vector.<HueGroup>
        {
            return _manager.groupsMap;
        }


        public function get entityMap():Vector.<HueEntity>
        {
            return _manager.entityMap;
        }


        public function get isReady():Boolean
        {
            return _manager.isReady;
        }


        public function get ipAddress():String
        {
            return _manager.ipAddress;
        }
        public function set ipAddress( value:String ):void
        {
            _manager.ipAddress = value;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}