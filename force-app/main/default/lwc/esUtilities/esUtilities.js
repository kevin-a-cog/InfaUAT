/*
 * Name			:	esUtilities
 * Author		:	Vignesh Divakaran
 * Created Date	: 	10/25/2022
 * Description	:	This LWC contains generic methods used in eSupport community.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Vignesh Divakaran		10/25/2022		I2RT-7256		Initial version.					N/A
 */

/*
 Method Name : sortBy
 Description : This method is callback function to sort data for lightning datatable.
 Parameters	 : String, called from sortBy, strField field name.
               Number, called from sortBy, intReverse sort order.
               Function, called from sortBy, primer.
 Return Type : None
 */
const sortBy = (strField, intReverse, primer) => {
    const key = primer
        ? function (x) {
              return primer(x[strField]);
          }
        : function (x) {
              return x[strField];
          };

    return function (a, b) {
        a = key(a);
        b = key(b);
        return intReverse * ((a > b) - (b > a));
    };
}

//Class body.
const esUtilities = {
	sortBy: sortBy
}
export { esUtilities };