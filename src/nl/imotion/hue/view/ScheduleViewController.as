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

    import nl.imotion.bindmvc.controller.BindController;
    import nl.imotion.hue.entities.HueSchedule;
    import nl.imotion.hue.model.HueModel;
    import nl.imotion.hue.util.VectorConverter;


    /**
     * @author Pieter van de Sluis
     */
    public class ScheduleViewController extends BindController
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES


        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function ScheduleViewController( viewComponent:DisplayObject )
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
            startEventInterest( defaultView, Event.COMPLETE, onFormSubmit );

            view.lights = VectorConverter.toArrayCollection( model.lightsMap );
            view.groups = VectorConverter.toArrayCollection( model.groupsMap );
        }

        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        private function get model():HueModel
        {
            return retrieveModel( HueModel.NAME ) as HueModel;
        }


        private function get view():ScheduleView
        {
            return defaultView as ScheduleView;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS

        private function onFormSubmit( e:Event ):void
        {
            model.addSchedule( view.schedule );
        }

    }
}