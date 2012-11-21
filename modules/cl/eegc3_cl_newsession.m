% 2010-11-26  Michele Tavella <michele.tavella@epfl.ch>

function session = eegc3_cl_newsession()

session = {};
session.subject = 'unset';
session.daytime = 'unset';
session.name = 'unset';
session.base = 'unset';
session.path = 'unset';
session.root = 'unset';
session.runs.all = {};
session.runs.online = {};
session.runs.offline = {};
session.trace.hostname = mt_hostname();
session.trace.datetime = eegc3_datetime();
session.trace.eegcversion = 0;
