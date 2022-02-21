page 65036 "Input Blade GoodsIn"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'GoodsIn Details';


    layout
    {
        area(Content)
        {
            field(ExpectedPallets; ExpectedPallets)
            {
                ApplicationArea = All;
                Caption = 'Expected Pallets';
            }
            field(ExpectedCartons; ExpectedCartons)
            {
                ApplicationArea = all;
                Caption = 'Expected Cartons';
            }
            field(ShippingCompany; ShippingCompany)
            {
                ApplicationArea = all;
                Caption = 'Shipping Company';
            }
            field(TrackingNumber; TrackingNumber)
            {
                ApplicationArea = all;
                Caption = 'Tracking Number';
            }
            field(ShippingMethod; ShippingMethod)
            {
                ApplicationArea = all;
                //OptionCaption = ' ,air,road,sea';
                Caption = 'Shipping Method';
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
                var
                    ShippingMethodErr: Label 'Please select shipping method.';
                begin
                    if ShippingMethod = ShippingMethod::Empty then
                        Error(ShippingMethodErr);
                    GoodsInInfoConfirmed := true;
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
    procedure GetBladeJobReference(): Text[30]
    begin
        //exit(BladeJobReference);
    end;

    procedure GetExpectedPallets(): Integer
    begin
        exit(ExpectedPallets);
    end;

    procedure GetExpectedCartons(): Integer
    begin
        exit(ExpectedCartons);
    end;

    procedure GetShippingCompany(): Text[50]
    begin
        exit(ShippingCompany)
    end;

    procedure GetTrackingNumber(): Code[20]
    begin
        exit(TrackingNumber);
    end;

    procedure GetShippingMethod(): Text[5]
    begin
        case ShippingMethod of
            ShippingMethod::Air:
                txtShippingMethod := 'air';
            ShippingMethod::Road:
                txtShippingMethod := 'road';
            ShippingMethod::Sea:
                txtShippingMethod := 'sea';
        end;
        exit(txtShippingMethod);
        //exit(ShippingMethod);
    end;

    procedure ActionConfirmed(): Boolean
    begin
        exit(GoodsInInfoConfirmed);
    end;

    var
        GoodsInInfoConfirmed: Boolean;
        ExpectedPallets: Integer;
        ExpectedCartons: Integer;
        ShippingCompany: Text[50];
        TrackingNumber: Code[20];
        ShippingMethod: Enum "Blade Shipping Method";
        txtShippingMethod: Text[5];



}
