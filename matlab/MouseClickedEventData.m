classdef MouseClickedEventData < event.EventData
    
    properties
        X
        Y
        ClickCount
        Button
        AltDown
        AltGraphDown
        ControlDown
    end
    
    methods
        function self = MouseClickedEventData(evt)
            self.X = evt.X;
            self.Y = evt.Y;
            self.ClickCount = evt.ClickCount;
            self.Button = evt.Button;
            self.AltDown = evt.AltDown;
            self.AltGraphDown = evt.AltGraphDown;
            self.ControlDown = evt.ControlDown;
        end
    end
    
end
