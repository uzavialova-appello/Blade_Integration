enum 65003 "Blade Whse Shipment Line Status"
{
    Extensible = true;

    value(0; Empty) { Caption = '', Locked = true; }
    value(1; "active") { Caption = 'active'; }
    value(2; "void") { Caption = 'void'; }

}