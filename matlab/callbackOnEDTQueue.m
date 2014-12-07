function callbackOnEDTQueue(varargin)
%CALLBACKONEDTQUEUE will place a callback on the EDT to asynchronously
%run a function.
%CALLBBACKONEDTQUEUE(FCN) will run function handle FCN once all previous
%methods dispatched to the EDT have completed.
%CALLBBACKONEDTQUEUE(FCN,ARG1,ARG2,...) ill run function handle FCN with
%arguments ARG1,ARG2...once all previous methods dispatched to the EDT
%have completed.
%Note that the function is still executing on the main Matlab thread. This
%function just delays when it will be called.

validateattributes(varargin{1}, {'function_handle'}, {});
callbackObj = handle(com.mathworks.jmi.Callback, 'callbackProperties');
set(callbackObj, 'delayedCallback', {@cbEval, varargin(:)});
callbackObj.postCallback;

function cbEval(~, ~, args)
feval(args{:});
