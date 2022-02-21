page 65034 "Input Blade Cancel Reason"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Specify the reason';


    layout
    {
        area(Content)
        {
            field(BladeCancelReason; BladeCancelReason)
            {
                ApplicationArea = All;
                Caption = 'Cancel Reason';

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionOk)
            {
                ApplicationArea = All;
                Caption = 'OK';
                InFooterBar = true;

                trigger OnAction()
                begin
                    ReasonCodeConfirmed := true;
                    CurrPage.Close();
                end;
            }
            action(ActionCancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }
    procedure GetBladeCancelReason(): Text[30]
    begin
        exit(BladeCancelReason);
    end;

    procedure ActionConfirmed(): Boolean
    begin
        exit(ReasonCodeConfirmed);
    end;

    var
        BladeCancelReason: Text[30];
        ReasonCodeConfirmed: Boolean;
}
