function [data smpr meta] = query(db,varargin)
% QUERY - Return cell array of waveforms organized as 
% sentences words or phonemes according to the query finest criteria.
% [wave fs metadata] = query(ADTobj, criterion1,value1,...);
% wave - Cell array of waveforms.
% Accessing the wave data: oneWord = wave{1};
% fs - Sample rate.
% metadata - Structure array describing waveforms
%
% Examples:
% wave = query(ADTobj, 'sentence', 'SA1')
% returns all instances of sentence 'SA1'.
% 
% wave = query (ADTobj, 'dialect', '~dr2')
% returns all sentences of dialect region other than dr2.
% 
% wave = query(ADTobj, 'phoneme', {'d', 'p'});
% returns all instances of phonemes 'd' or 'p'. 
% 
% wav = query(ADTobj, 'word', ‘sh*’);
% returns all instances of words starting with sh.
%
%
%See also query, filterdb, read, play.

   db = filterdb(db,varargin{1:end});
   [data smpr meta] = read(db);
end