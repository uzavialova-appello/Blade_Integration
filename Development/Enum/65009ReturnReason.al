enum 65009 "Return Reason"
{
    Extensible = true;

    value(0; Empty) { Caption = ' ', Locked = true; }
    value(1; "Over ordered") { Caption = 'Over ordered'; }
    value(2; "Survey Inaccurate") { Caption = 'Survey Inaccurate'; }
    value(3; "Wrong items ordered") { Caption = 'Wrong Items ordered'; }
    value(4; "Wrong items sent") { Caption = 'Wrong Items sent'; }
    value(5; "Faulty") { Caption = 'Faulty'; }
    value(6; "Other - Add to comments") { Caption = 'Other - Add to comments'; }
}