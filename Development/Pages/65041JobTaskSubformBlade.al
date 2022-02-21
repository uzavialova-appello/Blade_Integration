pageextension 65041 "Job Task Lines Subform Blade" extends "Job Task Lines Subform"
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
                Scope = Repeater;
                ToolTip = 'View all planning lines for the job. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a job (budget) or you can specify what you actually agreed with your customer that he should pay for the job (billable).';

                trigger OnAction()
                var
                    JobPlanningLine: Record "Job Planning Line";
                    JobPlanningLines: Page "Job Planning Lines";
                begin
                    TestField("Job No.");
                    JobPlanningLine.FilterGroup(2);
                    JobPlanningLine.SetRange("Job No.", "Job No.");
                    JobPlanningLine.SetRange("Job Task No.", "Job Task No.");
                    JobPlanningLine.FilterGroup(0);
                    JobPlanningLines.SetTableView(JobPlanningLine);
                    JobPlanningLines.Editable := true;
                    JobPlanningLines.MarkTobeSentActionVisible(true);
                    JobPlanningLines.Run;
                end;
            }
        }
    }
}