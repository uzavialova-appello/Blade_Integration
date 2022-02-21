enum 65005 "Blade Whse Receipt Line Status"
{
    Extensible = true;
    value(0; Empty) { Caption = ' ', Locked = true; }
    value(1; "awaiting_booking") { Caption = 'awaiting_booking'; }
    value(2; "awaiting_shipping") { Caption = 'awaiting_shipping'; }
    value(3; "awaiting_receiving") { Caption = 'awaiting_receiving'; }
    value(4; "awaiting_checkin") { Caption = 'awaiting_checkin'; }
    value(5; "awaiting_putaway") { Caption = 'awaiting_putaway'; }
    value(6; "completed") { Caption = 'completed'; }
    value(7; "cancelled") { Caption = 'cancelled'; }
    value(8; "awaiting_collection") { Caption = 'discrepancies'; }
    value(9; "pending_completion") { Caption = 'awaiting_collection'; }

}