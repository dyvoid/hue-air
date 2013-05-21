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

package nl.imotion.hue.exampleui.notes
{
    import nl.imotion.hue.manager.entities.HueEntity;
    import nl.imotion.hue.manager.entities.HueGroup;
    import nl.imotion.hue.manager.entities.HueLight;
    import nl.imotion.notes.Note;


    /**
     * @author Pieter van de Sluis
     */
    public class ModelReadyNote extends Note
    {
        // ____________________________________________________________________________________________________
        // PROPERTIES

        public static const MODEL_READY:String = "modelReady";

        private var _lightsMap:Vector.<HueLight>;
        private var _groupsMap:Vector.<HueGroup>;
        private var _entityMap:Vector.<HueEntity>;

        // ____________________________________________________________________________________________________
        // CONSTRUCTOR

        public function ModelReadyNote( lightsMap:Vector.<HueLight>, groupsMap:Vector.<HueGroup>, entityMap:Vector.<HueEntity> )
        {
            super( MODEL_READY );

            _lightsMap = lightsMap;
            _groupsMap = groupsMap;
            _entityMap = entityMap;
        }

        // ____________________________________________________________________________________________________
        // PUBLIC


        // ____________________________________________________________________________________________________
        // PRIVATE


        // ____________________________________________________________________________________________________
        // PROTECTED


        // ____________________________________________________________________________________________________
        // GETTERS / SETTERS

        public function get lightsMap():Vector.<HueLight>
        {
            return _lightsMap;
        }


        public function get groupsMap():Vector.<HueGroup>
        {
            return _groupsMap;
        }


        public function get entityMap():Vector.<HueEntity>
        {
            return _entityMap;
        }

        // ____________________________________________________________________________________________________
        // EVENT HANDLERS


    }
}