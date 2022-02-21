page 65035 "Input Blade Job Reference"
{
    PageType = NavigatePage;
    //PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Select job Blade reference.';
    SourceTable = "Job Planning Line";


    layout
    {
        area(Content)
        {
            field(BladeJobReference; BladeJobReference)
            {
                ApplicationArea = All;
                Caption = 'Job Reference';
                trigger OnLookup(var text: Text): Boolean
                begin
                    JobPlanningLineBuffer.Reset();
                    JobPlanningLineBuffer.DeleteAll();

                    JobPlanningLine.Reset();
                    JobPlanningLine.SetCurrentKey("Blade Reference", "Blade Status");
                    //JobPlanningLine.SetFilter("Blade Reference", '<>%1', '');
                    JobPlanningLine.SetFilter("Job No.", JobNo);//test
                    JobPlanningLine.SetFilter("Blade ID", '<>%1', '');
                    JobPlanningLine.SetFilter(JobPlanningLine."Blade Status", '<>%1&<>%2', JobPlanningLine."Blade Status"::cancelled, JobPlanningLine."Blade Status"::despatched);
                    if JobPlanningLine.FindSet() then begin
                        repeat
                            JobPlanningLineBuffer.Init();
                            JobPlanningLineBuffer.SetCurrentKey("Blade Reference", "Blade Status");
                            JobPlanningLineBuffer.SetRange("Blade Reference", JobPlanningLine."Blade Reference");
                            EntryInBufferExists := JobPlanningLineBuffer.FindFirst();

                            if not EntryInBufferExists then begin
                                JobPlanningLineBuffer."Job No." := JobPlanningLine."Job No.";
                                JobPlanningLineBuffer."Job Task No." := JobPlanningLine."Job Task No.";
                                JobPlanningLineBuffer."Line No." := JobPlanningLine."Line No.";
                            end;
                            //JobPlanningLineBuffer."Job Contract Entry No." := JobPlanningLine."Job Contract Entry No.";
                            JobPlanningLineBuffer."Blade Reference" := JobPlanningLine."Blade Reference";
                            //if JobPlanningLine."Blade ID" <> '' then
                            JobPlanningLineBuffer."Blade ID" := JobPlanningLine."Blade ID";
                            JobPlanningLineBuffer."Blade Status" := JobPlanningLine."Blade Status";

                            //end;
                            if EntryInBufferExists then
                                JobPlanningLineBuffer.Modify()
                            else
                                JobPlanningLineBuffer.Insert();
                        until JobPlanningLine.Next() = 0;
                        JobPlanningLineBuffer.Reset();
                        if Page.RunModal(0, JobPlanningLineBuffer) = Action::LookupOK then begin
                            BladeJobReference := JobPlanningLineBuffer."Blade Reference";
                            BladeId := JobPlanningLineBuffer."Blade ID";
                        end;
                    end;
                end;
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
                    JobReferenceConfirmed := true;
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
    procedure GetBladeId(): Text[30]
    begin
        exit(BladeId);
    end;

    procedure GetBladeJobReference(): Code[20]
    begin
        exit(BladeJobReference);
    end;

    procedure ActionConfirmed(): Boolean
    begin
        exit(JobReferenceConfirmed);
    end;

    procedure SetJobFilter(pJobNo: Code[20])
    begin
        JobNo := pJobNo;
    end;

    var
        BladeJobReference: Code[20];
        JobReferenceConfirmed: Boolean;
        JobPlanningLineBuffer: Record "Job Planning Line" temporary;
        JobPlanningLine: Record "Job Planning Line";
        JobNo: Code[20];
        EntryInBufferExists: Boolean;
        BladeId: code[30];
}
