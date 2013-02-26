package nl.imotion.hue.enums
{
    /**
     * @author Pieter van de Sluis
     */
    public final class Effect
    {

        // ____________________________________________________________________________________________________
        // PUBLIC

        public static const NONE        :String = "none";
        public static const COLOR_LOOP  :String = "colorloop";

        public static function getAll():Array
        {
            return [ NONE, COLOR_LOOP ];
        }
    }
}