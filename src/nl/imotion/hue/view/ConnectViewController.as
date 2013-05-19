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

package nl.imotion.hue.view
{
    import flash.display.DisplayObject;
    import flash.events.Event;

    import mx.controls.Alert;

    import nl.imotion.bindmvc.controller.BindController;
    import nl.imotion.hue.model.HueModel;
    import nl.imotion.hue.util.VectorConverter;
    import nl.imotion.hue.view.events.ConnectFormEvent;


    /**
     * @author Pieter van de Sluis
     */
    public class ConnectViewController extends BindController
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES


        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function ConnectViewController( viewComponent:DisplayObject )
        {
            super( viewComponent );

            init();
        }

        // ____________________________________________________________________________________________________
        // PUBLIC


        // ____________________________________________________________________________________________________
        // PRIVATE

        private function init():void
        {
            startEventInterest( view, [ ConnectFormEvent.DISCOVER, ConnectFormEvent.REGISTER, ConnectFormEvent.CONNECT ], handleLoginEvent );
        }

        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        private function get model():HueModel
        {
            return retrieveModel( HueModel.NAME ) as HueModel;
        }


        private function get view():ConnectView
        {
            return defaultView as ConnectView;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS

        private function handleLoginEvent( e:ConnectFormEvent ):void
        {
            view.enabled = false;

            switch ( e.type )
            {
                case ConnectFormEvent.DISCOVER:
                    model.discoverBridge( onDiscoverResult, onDiscoverFault );
                    break;

                case ConnectFormEvent.REGISTER:
                    model.ipAddress = e.loginData.ipAddress;
                    model.register( e.loginData.userName, e.loginData.deviceType, onRegisterResult, onRegisterFault );
                    break;

                case ConnectFormEvent.CONNECT:
                    model.connect( e.loginData );
                    break;
            }
        }


        private function onDiscoverFault( data:* ):void
        {
            Alert.show( "Hue Bridge could not be found", "Failed" );
            view.enabled = true;
        }


        private function onDiscoverResult( data:* ):void
        {
            if ( data is Array && data.length > 0 && data[ 0 ].internalipaddress )
            {
                view.enabled = true;
                view.setIpAddress( data[ 0 ].internalipaddress );
            }
            else
            {
                onDiscoverFault( null );
            }
        }


        private function onRegisterFault( data:* ):void
        {
            if ( data is String )
            {
                Alert.show( data, "Failed" );
            }
            else
            {
                Alert.show( "Registration failed", "Failed" );
            }

            view.enabled = true;
        }


        private function onRegisterResult( data:Object ):void
        {
            if ( !data[0].error )
            {
                view.enabled = true;
                view.registerSucces();
            }
            else
            {
                onRegisterFault( data[0].error.description );
            }
        }

    }
}