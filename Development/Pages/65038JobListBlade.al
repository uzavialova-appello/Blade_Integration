pageextension 65038 "Jobs Blade Status" extends "Job List"
{
    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;
                action("Sync Blade Status")
                {
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        BladeMgt: Codeunit "Blade Mgt.";
                        JobPlanningLine: Record "Job Planning Line";
                        BladeStatusMgt: Codeunit "Get Blade Statuses";
                    begin
                        //BladeMgt.SetJobPlanningLineFiltersUpdateStatus(JobPlanningLine);
                        //BladeMgt.GetJobPlanningLineStatuses(JobPlanningLine, false);
                        BladeStatusMgt.GetBladeJobPlannningLineStatus();
                    end;
                }
            }
        }
    }
}