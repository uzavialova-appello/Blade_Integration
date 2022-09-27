enum 65008 "Return Status"
{
    Extensible = true;

    value(0; Empty) { Caption = ' ', Locked = true; }
    value(1; "Collection arranged by I-F") { Caption = 'Collection arranged by I-F'; }
    value(2; "Collection arranged by Appello") { Caption = 'Collection arranged by Appello'; }
    value(3; "Collected from site") { Caption = 'Collected from site'; }
    value(4; "Delivered to I-F") { Caption = 'Delivered to I-F'; }
    value(5; "Complete") { Caption = 'Complete'; }

}