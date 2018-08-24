#1.49s (Original)
SELECT * from rms 
where `docType`="COURSEASSESSMENTPROGRESSDETAILS" 
AND `courseId`="glp-1534717988644"

#19.59ms (I re-wrote)
SELECT * from rms 
where id like 'glp-1534717988644%'
      and `docType`="COURSEASSESSMENTPROGRESSDETAILS" 
      and `courseId`="glp-1534717988644"


SELECT id, docType, scope, properties from ams where 
docType = 'actor-profile-node' and id like '%_glp-1534717988644' limit 1


CREATE INDEX ams_test_1 ON `ams` (docType, meta().id, scope, properties) USING GSI
WITH {"defer_build":true};
SELECT * FROM system:indexes WHERE name="ams_test";
BUILD INDEX ON `ams`(`ams_test_1`) USING GSI;

DROP INDEX `ams`.`ams_test` USING GSI;

#info
#https://blog.couchbase.com/create-right-index-get-right-performance/

CREATE INDEX `rms_docType_courseId` ON `rms`(`docType`,`courseId`) USING GSI
WITH {"defer_build":true};
BUILD INDEX ON `rms`(`rms_docType_courseId`) USING GSI;
SELECT * FROM system:indexes WHERE name="rms_docType_courseId";

(Original)
SELECT id, docType, scope, properties 
from ams where docType = 'actor-profile-node' 
and id like ‘%_glp-1533889842768'

(Proposed)
SELECT id, docType, scope, properties 
from ams where docType = 'actor-profile-node' 
and id like 'GLP-%_glp-1533889820113'