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
icmessage_dumpmessage(message);

icmessage_addclassifier(message, ...
	'cnbi_mi', ...
	'CNBI MI Classifier', ...
	icmessage_getvaluetype('prob'), ...
	icmessage_getlabeltype('biosig'));
icmessage_addclassifier(message, ...
	'cnbi_mi', ...
	'CNBI MI Classifier', ...
	icmessage_getvaluetype('prob'), ...
	icmessage_getlabeltype('biosig'));


icmessage_addclass(message, 'cnbi_mi', '0x300', 0.60);
icmessage_addclass(message, 'cnbi_mi', '0x300', 0.60);
icmessage_dumpmessage(message);

value = icmessage_getvalue(message, 'error', '0x300');
value = icmessage_getvalue(message, 'cnbi_mi', 'error');

value = icmessage_setvalue(message, 'error', '0x300', 1);
value = icmessage_setvalue(message, 'cnbi_mi', 'error', 1);

icmessage_delete(message);
icserializerrapid_delete(serializer);
