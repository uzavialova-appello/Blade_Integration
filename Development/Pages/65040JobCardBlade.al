pageextension 65040 "Job Card Blade" extends "Job Card"
{
    actions
    {
        modify(JobPlanningLines)
        {
            Visible = false;
        }
        addfirst("&Job")
        {
            action("Job Planning Lines")
            {
                ApplicationArea = Jobs;
                Caption = 'Job &Planning Lines';
                Image = JobLines;
                Promoted = true;
                PromotedCategory = Category6;
                ToolTip = 'View all planning lines for the job. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a job (Budget) or you can specify what you actually agreed with your customer that he should pay for the job (Billable).';

                trigger OnAction()
                var
                    JobPlanningLine: Record "Job Planning Line";
                    JobPlanningLines: Page "Job Planning Lines";
                begin
                    TestField("No.");
                    JobPlanningLine.FilterGroup(2);
                    JobPlanningLine.SetRange("Job No.", "No.");
                    JobPlanningLine.FilterGroup(0);
                    JobPlanningLines.SetJobTaskNoVisible(true);
                    JobPlanningLines.SetTableView(JobPlanningLine);
                    JobPlanningLines.Editable := true;
                    JobPlanningLines.MarkTobeSentActionVisible(false);
                    JobPlanningLines.Run;
                end;
            }
        }

    }
}