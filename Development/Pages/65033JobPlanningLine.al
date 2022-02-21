pageextension 65033 "Job Planning Lines Blade" extends "Job Planning Lines"
{
    layout
    {
        addafter("Qty. to Transfer to Journal")
        {
            field("Qty. to Send to Blade"; "Qty. to Send to Blade")
            {
                ApplicationArea = all;
                //Editable = AllowEditBladeFields;
            }
            field("To Be Sent To Blade"; "To Be Sent To Blade")
            {
                ApplicationArea = all;
            }
            field("Available Qty."; "Available Qty.")
            {
                ApplicationArea = all;
                //Editable = AllowEditBladeFields;
            }
            field("Blade Item ID"; "Blade Item ID")
            {
                ApplicationArea = all;
            }
            field("Blade ID"; "Blade ID")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Blade Reference"; "Blade Reference")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Blade Status"; "Blade Status")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Blade Line ID"; "Blade Line ID")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Blade Line Status"; "Blade Line Status")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Sent to Blade"; "Sent to Blade")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Line Sent to Blade"; "Line Sent to Blade")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Qty. Sent to Blade"; "Qty. Sent to Blade")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Blade Cancel Reason"; "Blade Cancel Reason")
            {
                ApplicationArea = all;
            }
            field("Stock is Available"; "Stock is Available")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;

                action("Send Job Planning Lines")
                {
                    ApplicationArea = All;
                    Image = SendTo;

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobPlanningLine: Record "Job Planning Line";
                        OldJobPlanningLine: Record "Job Planning Line";
                        JobEntryNoFilter: Text;
                        NothingToSendErr: Label 'There is nothing to sent to Blade. Please mark the planning lines you want to send.';
                    begin
                        Job.Get(Rec."Job No.");
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetRange("Job No.", Rec."Job No.");
                        JobPlanningLine.SetRange("To Be Sent To Blade", true);
                        if not JobPlanningLine.FindSet() then Error(NothingToSendErr);
                        BladeMgt.GetAvailableQtyJob(Job);
                        BladeMgt.CheckItemAvailabilityJob(JobPlanningLine);
                        OldJobPlanningLine.Copy(JobPlanningLine);
                        BladeMgt.SendAvailableJobPlanningLines(JobPlanningLine);
                        BladeMgt.SendNonAvailableJobPlanningLines(OldJobPlanningLine);
                    end;
                }
                action("Cancel Job Order")
                {
                    ApplicationArea = All;
                    Image = CancelAllLines;

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetCurrentKey("Blade Reference");
                        JobPlanningLine.SetRange("Blade Reference", Rec."Blade Reference");
                        if JobPlanningLine.FindSet() then
                            BladeMgt.CancelSalesOrderFromJob(JobPlanningLine);
                    end;
                }
                action("Cancel Job Planning Line")
                {
                    ApplicationArea = All;
                    Image = Cancel;

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        //start
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetCurrentKey("Blade Reference");
                        JobPlanningLine.SetRange("Blade Reference", Rec."Blade Reference");
                        if JobPlanningLine.FindSet() then begin
                            if JobPlanningLine.Count > 1 then
                                BladeMgt.CancelSalesOrderLineFromJob(Rec)
                            else
                                BladeMgt.CancelSalesOrderFromJob(JobPlanningLine);
                        end;
                        //end
                        //BladeMgt.CancelSalesOrderLineFromJob(Rec); removed
                    end;
                }
                action("Update Shipping Address")
                {
                    ApplicationArea = All;
                    Image = UpdateShipment;

                    trigger OnAction()
                    var
                        NotSentErr: Label 'You cannot update the Shipping Address for this line,because it hasn''t been sent to Blade yet.';
                        DespatchedErr: Label 'The Job Order %1 has already been despatched';
                    begin
                        if ("Blade Status" = "Blade Status"::despatched) then Error(DespatchedErr, Rec."Blade Reference");
                        if ("Blade ID" <> '') and "Sent to Blade" then
                            BladeMgt.UpdateJobPlanningLineShippingAddress(Rec)
                        else
                            Error(NotSentErr);
                    end;
                }
                action("Add New Line to an existing Job Order")
                {
                    ApplicationArea = All;
                    Image = SendTo;

                    trigger OnAction()
                    var
                        DuplicateErr: Label 'The job Planning Line has already been sent to Blade under Reference No. %1';
                        Job: Record Job;
                        NotEnoughAvailableQtyConfirm: Label 'There is not enough available qty. for the Item No.%1.Do you want to proceed?';
                        ProcessCancelledErr: Label 'The process has been cancelled.';
                    //JobPlanningLine:Record "Job Planning Line";
                    begin
                        if "Line Sent to Blade" then Error(DuplicateErr, Rec."Blade Reference");
                        Job.Get(Rec."Job No.");
                        BladeMgt.GetAvailableQtyJob(Job);
                        Commit();
                        CurrPage.Update(true);
                        if "Available Qty." < "Qty. to Send to Blade" then if not Confirm(NotEnoughAvailableQtyConfirm, false, "No.") then Error(ProcessCancelledErr);
                        BladeMgt.AddNewJobLine(Rec);
                    end;
                }
                action("Update Job Planning Line Quantity")
                {
                    ApplicationArea = All;
                    Image = UpdateUnitCost;

                    trigger OnAction()
                    var
                        DespatchedErr: Label 'The Job Order %1 has already been despatched.';
                        NotSentErr: Label 'You cannot update the quantity for this line,because it hasn''t been sent to Blade yet.';
                    begin
                        if ("Blade Line ID" <> '') and ("Line Sent to Blade") then
                            BladeMgt.UpdateJobPlannningLineQty(Rec)
                        else
                            Error(NotSentErr);
                        if ("Blade Status" = "Blade Status"::despatched) then Error(DespatchedErr, Rec."Blade Reference");
                    end;
                }
                action("Get Available Qty.")
                {
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        Job: Record Job;
                    begin
                        Job.Get(Rec."Job No.");
                        BladeMgt.GetAvailableQtyJob(Job);
                    end;
                }
                action("Mark All Job Planning Lines")
                {
                    ApplicationArea = All;
                    Image = Select;
                    Visible = ActionVisible;

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                        Job: Record Job;
                        counter: Integer;
                        ApplyUsageLinkErr: Label 'Apply Usage Link is disabled.It''s not possible to calculate the Qty. To Send to Blade. Please, review them and mark them maunally.';
                    begin
                        Job.Get(Rec."Job No.");
                        if not Job."Apply Usage Link" then Error(ApplyUsageLinkErr);
                        Clear(counter);
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetRange("Job No.", Rec."Job No.");
                        JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
                        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
                        JobPlanningLine.SetRange("Sent to Blade", false);
                        JobPlanningLine.SetFilter("Remaining Qty.", '<>%1', 0);
                        if not JobPlanningLine.FindFirst() then Error('There is nothing to mark. Review the lines.');
                        if JobPlanningLine.FindSet() then begin
                            repeat
                                JobPlanningLine.Validate("Qty. to Send to Blade", JobPlanningLine."Remaining Qty.");
                                JobPlanningLine."To Be Sent To Blade" := true;
                                if JobPlanningLine.Modify() then counter += 1;
                            until JobPlanningLine.Next() = 0;
                        end;
                        Message('Number of records marked is %1. Please review the quantities before sending them to Blade.', counter);
                    end;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        AllowEditBladeFields := BladeMgt.BladeFieldsEditable(UserId);
    end;

    trigger OnOpenPage()
    var
    begin
        ActionVisible := ActionMarkBulkJobPlanningLinesVisible;
    end;

    procedure MarkTobeSentActionVisible(pVisible: Boolean)
    begin
        ActionMarkBulkJobPlanningLinesVisible := pVisible;
    end;

    var
        BladeMgt: Codeunit "Blade Mgt.";
        [InDataSet]
        AllowEditBladeFields: Boolean;
        [InDataSet]
        ActionMarkBulkJobPlanningLinesVisible: Boolean;
        [InDataSet]
        ActionVisible: Boolean;
}
