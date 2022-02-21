//enum 65001 "Blade Sales Order Status"
enum 65001 "Blade Whse Shipment Status"
{
    Extensible = true;

    value(0; Empty) { Caption = ' ', Locked = true; }
    value(1; "draft") { Caption = 'draft'; }
    value(2; "awaiting_allocation") { Caption = 'awaiting_allocation'; }
    value(3; "hung") { Caption = 'hung'; }
    value(4; "returned") { Caption = 'returned'; }
    value(5; "awaiting_payment") { Caption = 'awaiting_payment'; }
    value(6; "awaiting_picking") { Caption = 'awaiting_picking'; }
    value(7; "awaiting_despatch") { Caption = 'awaiting_despatch'; }
    value(8; "backorder_release") { Caption = 'backorder_release'; }
    value(9; "backorder") { Caption = 'backorder'; }
    value(10; "cancelled") { Caption = 'cancelled'; }
    value(11; "return_open") { Caption = 'return_open'; }
    value(12; "item_refunded") { Caption = 'item_refunded'; }
    value(13; "item_replaced") { Caption = 'item_replaced'; }
    value(14; "awaiting_collection") { Caption = 'awaiting_collection'; }
    value(15; "despatched") { Caption = 'despatched'; }

}