rollout test "test"
(
  multiListBox mlb "MultiListBox" items:#("A","B","C")
  on mlb selectionEnd do format "selectionEnd: %\n" mlb.selection
)
rof=newrolloutfloater "tester" 200 300
addrollout test rof
