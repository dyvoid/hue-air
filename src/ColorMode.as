package
{
    /**
     * @author Pieter van de Sluis
     */
    public final class ColorMode
    {

        // ____________________________________________________________________________________________________
        // PUBLIC

        public static const HUE_SATURATION      :String = "hs";
        public static const COLOR_TEMPERATURE   :String = "ct";
        public static const XY                  :String = "xy";


        public static function getAll():Array
        {
            return [ HUE_SATURATION, COLOR_TEMPERATURE, XY ];
        }

    }
}