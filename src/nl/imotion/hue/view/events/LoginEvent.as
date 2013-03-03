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

package nl.imotion.hue.view.events
{
    import flash.events.Event;

    import nl.imotion.hue.vo.VOLogin;


    /**
     * @author Pieter van de Sluis
     */
    public class LoginEvent extends Event
    {
        public static const DISCOVER        :String = "discover";
        public static const REGISTER        :String = "register";
        public static const CONNECT         :String = "connect";

        private var _loginData:VOLogin;

        public function LoginEvent(type:String, loginData:VOLogin = null, bubbles:Boolean = false, cancelable:Boolean = false):void
        {
            super(type, bubbles, cancelable);
            this._loginData = loginData;
        }

        public function get loginData():VOLogin
        {
            return this._loginData;
        }

        override public function clone():Event
        {
            return new LoginEvent(this.type, this._loginData, this.bubbles, this.cancelable);
        }

        override public function toString():String
        {
            return formatToString("LoginEvent", "type", "loginData", "bubbles", "cancelable", "eventPhase");
        }
    }
}