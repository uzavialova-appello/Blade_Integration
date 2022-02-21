enum 65000 "Blade Item Status"
{
    Extensible = true;

    value(0; Empty) { Caption = ' ', Locked = true; }
    value(1; "active") { Caption = 'active'; }
    value(2; "draft") { Caption = 'draft'; }
    value(3; "discontinued") { Caption = 'discontinued'; }
}