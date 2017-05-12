<%
    ui.includeCss("drugorders", "drugorders.css")
%>

<!--
    Form to enter and select (based on auto-complete options) a medication plan.
-->

<div id="medPlanWindow" class="dialog">
    <div class="dialog-header">
        <h3 id="dialog-heading">${ ui.message("SELECT MEDICATION PLAN") }</h3>
    </div><br/>
    
    <div class="addMedicationPlanWindow">
        <form method="post" id="planForm">
            <div class="fields"><label><strong>Enter Plan Name </strong></label><br/>
                <input type="text" id="planName" name="planName" oninput="autoCompletePlan()" />
            </div><br/><br/>            
            <button class="cancel pull-right" id="btn-place" type="button" onclick="hideMedicationPlanOrderWindow()">${ ui.message("Cancel") }</button>
        </form>
    </div>
</div>

<script type="text/javascript">
    jq( function() {
        jq( "#planName" ).autocomplete({
            source: function( request, response ) {
                var results = [];
                jq.getJSON('${ ui.actionLink("getPlanNameSuggestions") }',
                    {
                      'query': request.term, 
                    })
                .success(function(data) {
                    for (index in data) {
                        var item = data[index];
                        results.push(item.name);
                        }
                    response( results );
                })
                .error(function(xhr, status, err) {
                    alert('AJAX error ' + err);
                });
            }
        } )
    });
</script>
        
<!--
    Form displaying the details of the selected medication plan.
    This form provides check-boxes corresponding to each drug in the plan, allowing Physician to select drugs to be ordered.
    The form notifies the Physician if the Patient is allergic to the drug or if there is an active order for the drug.
-->
    
<% if(medplans.size() > 0) { %>

    <div id="medPlanDetailsWindow" class="dialog">
        <form method="post">    
            
            <div class="dialog-header">
                <h3 id="dialog-heading">${ ui.message("STANDARD MEDICATION PLAN") }</h3>
            </div>
            
            <input type="hidden" id="selectedPlan" name="selectedPlan" value="${ planName }" />
            <h5 class="align-center"><strong>${ planName.toUpperCase() }</strong></h5><br/>
            
            <div id="medPlansBlock" class="fields">
                <% medplans.each { medplan -> %>
                    <div class="planDrugName">
                        <!--
                            Disable options to select a medication plan drug if an active order for that drug exists.
                        -->
                        <% if(currentOrders.contains(medplan.drugId.getDisplayString())) { %>
                            <input type="checkbox" class="unchecked" disabled="disabled" />
                        <% } else { %>
                            <input type="checkbox" class="groupCheckBox" name="groupCheckBox" value="${ medplan.drugId }" checked="true" />
                        <% } %>
                        
                        <i class="icon-plus-sign  edit-action" title="${ ui.message("Show") }"></i>
                        <i class="icon-minus-sign edit-action" title="${ ui.message("Hide") }"></i>
                        <strong>${ medplan.drugId.getDisplayString() }</strong>
                    </div>
                        
                    <div class="drugDetails">
                        ${ medplan.dose } ${ medplan.doseUnits.getDisplayString() }, ${ medplan.quantity } ${ medplan.quantityUnits.getDisplayString() } <br/>
                                
                        <!--
                            Display a note if an active order for the selected drug exists.
                        -->
                        
                        <% if(currentOrders.contains(medplan.drugId.getDisplayString())) { %>
                            <div id="view_order_detail">
                                <label>Note: Drug is currently prescribed to this patient.</label>
                                <label>Cannot place multiple orders for the same drug.</label>
                            </div>
                        <% } %>
                        
                        <!--
                            Display a note if Patient is allergic to the drug.
                            Display a field to enter the reason to order the allergic drug.
                        -->
                        
                        <% if(allergicDrugs.contains(medplan.drugId.getDisplayString())) { %>
                            <br/> NOTE: Patient is allergic to this drug <br/>
                            Enter reasons to order this drug <br/>
                            <input type="textarea" maxlength="255" class="planOrderReason" name="planOrderReason" />
                        <% } %>
                    </div><br/>
                        
                    <div class="groupBlock">
                        <div id="view_order_detail">
                            <div id="order_label">Dose</div>
                            <div id="order_value">${ medplan.dose }</div>
                        </div>

                        <div id="view_order_detail">
                            <div id="order_label">Dose units</div>
                            <div id="order_value">${ medplan.doseUnits.getDisplayString() }</div>
                        </div>

                        <div id="view_order_detail">
                            <div id="order_label">Route</div>
                            <div id="order_value">${ medplan.route.getDisplayString() }</div>
                        </div>

                        <div id="view_order_detail">
                            <div id="order_label">Quantity</div>
                            <div id="order_value">${ medplan.quantity }</div>
                        </div>

                        <div id="view_order_detail">
                            <div id="order_label">Qnty units</div>
                            <div id="order_value">${ medplan.quantityUnits.getDisplayString() }</div>
                        </div>

                        <div id="view_order_detail">
                            <div id="order_label">Duration</div>
                            <div id="order_value">${ medplan.duration }</div>
                        </div>

                        <div id="view_order_detail">
                            <div id="order_label">Durn units</div>
                            <div id="order_value">${ medplan.durationUnits.getDisplayString() }</div>
                        </div>

                        <div id="view_order_detail">
                            <div id="order_label">Frequency</div>
                            <div id="order_value">${ medplan.frequency }</div>
                        </div>
                    </div>
                <% } %>
            </div>

            <input type="hidden" id="selectMedPlan" name="action" value="selectMedPlan" />
            <button class="confirm pull-right" id="selectPlanButton" type="submit">${ ui.message("Select") }</button>
            <button class="cancel" id="btn-place" type="button" onclick="hideMedicationPlansWindow()">${ ui.message("Cancel") }</button>
        </form>
    </div>
    
    <script type="text/javascript">
        jq("#activeOrderWindow").hide();
        jq("#medPlanDetailsWindow").show();       

        jq(".icon-plus-sign").click(function(){
            jq(this).parent().nextAll(".groupBlock").first().show();
            jq(this).hide();
            jq(this).next(".icon-minus-sign").show();
        });

        jq(".icon-minus-sign").click(function(){
            jq(this).parent().nextAll(".groupBlock").first().hide();
            jq(this).hide();
            jq(this).prev(".icon-plus-sign").show();
        });
    </script>
<% } %>