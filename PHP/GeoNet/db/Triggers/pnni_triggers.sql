-- First, add this entry to your TNSNAMES.ora file:
GEONETDEV.OSS.SPRINT.COM =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = petey)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = GEONET)
    )
  )

-- Connect to your database as the owner of the switchinfo, historical, ipconversion, and portconversion tables.
-- Run the following to create a database link to the geonet schema
create database link GEONETDEV CONNECT TO "pnni_users" IDENTIFIED BY "pnni_users" 
    using 'GEONETDEV.OSS.SPRINT.COM';
  

-- Run the following trigger creation script, preferably one by one and make sure
-- you get the following return message: 

-- Trigger created.

-- I already checked the syntax so you shouldn't have any problems. 
-- But if you get any error message, run the following where name is the name of the trigger you just created:
select * from user_errors where lower(name) = 'repli_historical_ai_row';
-- It gives you the errors in the trigger creation sql.
-- Please let me know if you have any problems with that.

-- Also, the triggers are very specific to your database structure,
-- if any changes are made, the triggers need to be updated to reflect the changes. 
-- So please, let me know when you make changes.


CREATE OR REPLACE TRIGGER repli_portconversion_AI_ROW
AFTER INSERT ON pnni.portconversion
FOR EACH ROW
BEGIN
  INSERT INTO geonet.portconversion@geonetdev (asxport, engport)
    VALUES (:new.asxport, :new.engport);
END;
/
SHOW ERRORS

CREATE OR REPLACE TRIGGER repli_portconversion_AU_ROW
AFTER UPDATE ON pnni.portconversion
FOR EACH ROW
BEGIN
  UPDATE geonet.portconversion@geonetdev 
    SET asxport = :new.asxport, engport = :new.engport 
    WHERE asxport = :old.asxport and engport = :old.engport;
END;
/
SHOW ERRORS

--
CREATE OR REPLACE TRIGGER repli_ipconversion_AI_ROW
AFTER INSERT ON pnni.ipconversion
FOR EACH ROW
BEGIN
  INSERT INTO geonet.ipconversion@geonetdev (clli, ip, fabric, public_snmp, private_snmp)
    VALUES (:new.clli, :new.ip, :new.fabric, :new.public_snmp, :new.private_snmp);
END;
/
SHOW ERRORS

CREATE OR REPLACE TRIGGER repli_ipconversion_AU_ROW
AFTER UPDATE ON pnni.ipconversion
FOR EACH ROW
BEGIN
  UPDATE geonet.ipconversion@geonetdev 
    SET clli = :new.clli, ip = :new.ip, fabric = :new.fabric
      , public_snmp = :new.public_snmp, private_snmp = :new.private_snmp 
    WHERE clli = :old.clli and ip = :old.ip;
END;
/
SHOW ERRORS

--
CREATE OR REPLACE TRIGGER repli_switchinfo_BD_ROW
BEFORE DELETE ON pnni.switchinfo
FOR EACH ROW
BEGIN
  delete geonet.switchinfo@geonetdev where customer=:old.customer and connection=:old.connection 
      and connectionalias=:old.connectionalias and nvcid=:old.nvcid and linerate=:old.linerate 
      and clli=:old.clli and encid=:old.encid and ip=:old.ip and asxport=:old.asxport and engport=:old.engport
      and vp=:old.vp and cbrnum=:old.cbrnum and qos=:old.qos and bandwidth=:old.bandwidth
      and endpoint=:old.endpoint and endclli=:old.endclli and endport=:old.endport and endvp=:old.endvp
      and vc=:old.vc and endvc=:old.endvc and pollfrequency=:old.pollfrequency 
      and connectiontype=:old.connectiontype and testtype=:old.testtype;
END;
/
SHOW ERRORS

--
CREATE OR REPLACE TRIGGER repli_switchinfo_AI_ROW
AFTER INSERT ON pnni.switchinfo
FOR EACH ROW
BEGIN
  INSERT INTO geonet.switchinfo@geonetdev (customer, connection, connectionalias, nvcid
      , linerate, clli, encid, ip, asxport, engport, vp, cbrnum, qos, bandwidth
      , endpoint, endclli, endport, endvp, vc, endvc, pollfrequency, connectiontype
      , testtype)
    VALUES (:new.customer, :new.connection, :new.connectionalias, :new.nvcid
      , :new.linerate, :new.clli, :new.encid, :new.ip, :new.asxport, :new.engport, :new.vp, :new.cbrnum, :new.qos, :new.bandwidth
      , :new.endpoint, :new.endclli, :new.endport, :new.endvp, :new.vc, :new.endvc, :new.pollfrequency, :new.connectiontype
      , :new.testtype);
END;
/
SHOW ERRORS


CREATE OR REPLACE TRIGGER repli_switchinfo_AU_ROW
AFTER UPDATE ON pnni.switchinfo
FOR EACH ROW
BEGIN
  UPDATE geonet.switchinfo@geonetdev 
    SET customer = :new.customer,
        connection = :new.connection, 
        connectionalias = :new.connectionalias, 
        nvcid = :new.nvcid,
        linerate = :new.linerate, 
        clli = :new.clli, 
        encid = :new.encid, 
        ip = :new.ip, 
        asxport = :new.asxport, 
        engport = :new.engport, 
        vp = :new.vp, 
        cbrnum = :new.cbrnum, 
        qos = :new.qos, 
        bandwidth = :new.bandwidth,
        endpoint = :new.endpoint, 
        endclli = :new.endclli, 
        endport = :new.endport, 
        endvp = :new.endvp, 
        vc = :new.vc, 
        endvc = :new.endvc, 
        pollfrequency = :new.pollfrequency, 
        connectiontype = :new.connectiontype,
        testtype = :new.testtype
    WHERE customer = :old.customer 
      and connection = :old.connection
      and clli = :old.clli
      and ip = :old.ip
      and asxport = :old.asxport
      and engport = :old.engport
      and vp = :old.vp
      and vc = :old.vc
      and endpoint = :old.endpoint
      and cbrnum = :old.cbrnum
      ;
END;
/
SHOW ERRORS

--
CREATE OR REPLACE TRIGGER repli_historical_BD_ROW
BEFORE DELETE ON pnni.historical
FOR EACH ROW
BEGIN
  delete geonet.historical@geonetdev where tracenum=:old.tracenum and pathindex=:old.pathindex 
      and customer=:old.customer and currentpath=:old.currentpath and timechanged=:old.timechanged 
      and timeupdated=:old.timeupdated and connection=:old.connection and connectiontype=:old.connectiontype 
      and hop=:old.hop and inport=:old.inport
      and invp=:old.invp and invc=:old.invc and clli=:old.clli and outport=:old.outport
      and outvp=:old.outvp and outvc=:old.outvc and inportinpututil=:old.inportinpututil 
      and inportoutpututil=:old.inportoutpututil and outportinpututil=:old.outportinpututil 
      and outportoutpututil=:old.outportoutpututil and inportinputallocatedbw=:old.inportinputallocatedbw 
      and inportoutputallocatedbw=:old.inportoutputallocatedbw and outportinputallocatedbw=:old.outportinputallocatedbw
      and outportoutputallocatedbw=:old.outportoutputallocatedbw and inportatmrate=:old.inportatmrate 
      and outportatmrate=:old.outportatmrate and nvcid=:old.nvcid and fmscircuitid=:old.fmscircuitid 
      and citypair=:old.citypair and details=:old.details;
END;
/
SHOW ERRORS

--
CREATE OR REPLACE TRIGGER repli_historical_AI_ROW
AFTER INSERT ON pnni.historical
FOR EACH ROW
BEGIN
  INSERT INTO geonet.historical@geonetdev (tracenum, pathindex, customer
    , currentpath, timechanged, timeupdated, connection, connectiontype
    , hop, inport, invp, invc, clli, outport, outvp, outvc
    , inportinpututil, inportoutpututil, outportinpututil
    , outportoutpututil, inportinputallocatedbw, inportoutputallocatedbw
    , outportinputallocatedbw, outportoutputallocatedbw
    , inportatmrate, outportatmrate, nvcid
    , fmscircuitid, citypair, details)
    VALUES (:new.tracenum, :new.pathindex, :new.customer
    , :new.currentpath, :new.timechanged, :new.timeupdated, :new.connection, :new.connectiontype
    , :new.hop, :new.inport, :new.invp, :new.invc, :new.clli, :new.outport, :new.outvp, :new.outvc
    , :new.inportinpututil, :new.inportoutpututil, :new.outportinpututil
    , :new.outportoutpututil, :new.inportinputallocatedbw, :new.inportoutputallocatedbw
    , :new.outportinputallocatedbw, :new.outportoutputallocatedbw
    , :new.inportatmrate, :new.outportatmrate, :new.nvcid
    , :new.fmscircuitid, :new.citypair, :new.details);
END;
/
SHOW ERRORS

CREATE OR REPLACE TRIGGER repli_historical_AU_ROW
AFTER UPDATE ON pnni.historical
FOR EACH ROW
BEGIN
  UPDATE geonet.historical@geonetdev 
    SET tracenum = :new.tracenum, 
      pathindex = :new.pathindex, 
      customer = :new.customer,
      currentpath = :new.currentpath, 
      timechanged = :new.timechanged, 
      timeupdated = :new.timeupdated, 
      connection = :new.connection, 
      connectiontype = :new.connectiontype,
      hop = :new.hop, 
      inport = :new.inport, 
      invp = :new.invp, 
      invc = :new.invc, 
      clli = :new.clli, 
      outport = :new.outport, 
      outvp = :new.outvp, 
      outvc = :new.outvc,
      inportinpututil = :new.inportinpututil, 
      inportoutpututil = :new.inportoutpututil, 
      outportinpututil = :new.outportinpututil,
      outportoutpututil = :new.outportoutpututil, 
      inportinputallocatedbw = :new.inportinputallocatedbw, 
      inportoutputallocatedbw = :new.inportoutputallocatedbw,
      outportinputallocatedbw = :new.outportinputallocatedbw, 
      outportoutputallocatedbw = :new.outportoutputallocatedbw,
      inportatmrate = :new.inportatmrate, 
      outportatmrate = :new.outportatmrate, 
      nvcid = :new.nvcid,
      fmscircuitid = :new.fmscircuitid, 
      citypair = :new.citypair, 
      details = :new.details
    WHERE tracenum = :old.tracenum 
      and pathindex = :old.pathindex
    ;
END;
/
SHOW ERRORS

drop trigger repli_portconversion_AI_ROW;
drop trigger repli_portconversion_AU_ROW;
drop trigger repli_ipconversion_AI_ROW;
drop trigger repli_ipconversion_AU_ROW;
drop trigger repli_switchinfo_AI_ROW;
drop trigger repli_switchinfo_AU_ROW;
drop trigger repli_historical_AI_ROW;
drop trigger repli_historical_AU_ROW;


--- log in as geonet
--- to populate our database
delete portconversion;
insert into portconversion select * from pnni.portconversion@ntacdata;
select * from portconversion where rownum < 5;
commit;

delete ipconversion;
insert into ipconversion select * from pnni.ipconversion@ntacdata;
select * from ipconversion where rownum < 5;
commit;

delete switchinfo;
insert into switchinfo select * from pnni.switchinfo@ntacdata;
select * from switchinfo where rownum < 5;
commit;

delete historical;
insert into historical select * from pnni.historical@ntacdata where currentpath = 1;
select * from historical where rownum < 5;
commit;

