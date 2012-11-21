function support = eegserver_mi_new_support(settings, rejection, integration)

fs = settings.acq.sf;

support = {};
% The whole loop is made for two classes only, anyway...
support.dist.uniform = [0.5 0.5];
support.dist.nan = [NaN NaN];
support.dist.inf = [Inf Inf];
support.packets = 0;
support.cprobs = support.dist.inf;
support.nprobs = support.dist.uniform;
support.rejection = rejection;
support.integration = integration;
