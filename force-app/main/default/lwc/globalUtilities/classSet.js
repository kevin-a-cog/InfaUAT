/*
 * Name			:	classSet
 * Author		:	Vignesh Divakaran
 * Created Date	: 	7/24/2023
 * Description	:	Utility class to add & return computed class names.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Vignesh Divakaran		7/24/2023		I2RT-8640   	Initial version.					N/A
 */

const proto = {
    add(className) {
        if (typeof className === 'string') {
            this[className] = true;
        }
        else {
            Object.assign(this, className);
        }
        return this;
    },
    toString() {
        return Object.keys(this)
            .filter(key => this[key])
            .join(' ');
    }
}

export function classSet(config) {
    if (typeof config === 'string') {
        const key = config;
        config = {};
        config[key] = true;
    }
    return Object.assign(Object.create(proto), config);
}