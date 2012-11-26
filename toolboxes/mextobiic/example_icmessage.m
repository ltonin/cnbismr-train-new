%   Copyright (C) 2010 Michele Tavella <michele.tavella@epfl.ch>
%
%   This file is part of the mexctobiic wrapper
%
%   The libndf library is free software: you can redistribute it and/or
%   modify it under the terms of the version 3 of the GNU General Public
%   License as published by the Free Software Foundation.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

clear all;

message = icmessage_new();
serializer = icserializerrapid_new(message);

icmessage_addclassifier(message, ...
	'cnbi_mi', 'CNBI MI Classifier', ...
	icmessage_getvaluetype('prob'), icmessage_getlabeltype('biosig'));
icmessage_addclass(message, 'cnbi_mi', '0x300', 0.60);
icmessage_addclass(message, 'cnbi_mi', '0x301', 0.40);
icmessage_dumpmessage(message);

icmessage_addclassifier(message, ...
	'cnbi_erp', 'CNBI ErrP Classifier', ...
	icmessage_getvaluetype('prob'), icmessage_getlabeltype('class'));
icmessage_addclass(message, 'cnbi_erp', 'detection', 0.85);
icmessage_dumpmessage(message);

value = icmessage_getvalue(message, 'cnbi_mi', '0x300');
disp(['[icmessage] Value: ' num2str(value)]);
icmessage_setvalue(message, 'cnbi_mi', '0x300', 1000);
value = icmessage_getvalue(message, 'cnbi_mi', '0x301');
disp(['[icmessage] Value: ' num2str(value)]);

buffer = icmessage_serialize(message, serializer);
disp(['[icmessage] Sender has: ' buffer]);

message2 = icmessage_new();
serializer2 = icserializerrapid_new(message2);

icmessage_deserialize(message2, serializer2, buffer);
buffer2 = icmessage_serialize(message2, serializer2);
disp(['[icmessage] Receiver got: ' buffer2]);

disp('[icmessage] Stress test with 20s loop at 64Hz');
tic;
it = 0;
while(toc < 20)
    buffer = icmessage_serialize(message, serializer2);
    icmessage_deserialize(message2, serializer2, buffer);
    it = it + 1;
    pause(1/64);
end

icmessage_delete(message);
icmessage_delete(message2);
icserializerrapid_delete(serializer);
icserializerrapid_delete(serializer2);
