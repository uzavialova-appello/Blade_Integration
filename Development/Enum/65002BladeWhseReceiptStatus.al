//enum 65002 "Blade Purch Order Status"
enum 65002 "Blade Whse Receipt Status"
{
    Extensible = true;
    value(0; Empty) { Caption = ' ', Locked = true; }
    value(1; "draft") { Caption = 'draft'; }
    value(2; "cancelled") { Caption = 'cancelled'; }
    value(3; "awaiting_approval") { Caption = 'awaiting_approval'; }
    value(4; "awaiting_booking") { Caption = 'awaiting_booking'; }
    value(5; "rejected") { Caption = 'rejected'; }
    value(6; "open") { Caption = 'open'; }
    value(7; "completed") { Caption = 'completed'; }
    value(8; "discrepancies") { Caption = 'discrepancies'; }
    value(9; "pending_completion") { Caption = 'pending_completion'; }

}