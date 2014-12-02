function varargout = compileJava(file)
% Compile Java file using JOGL library JARs.
%   compileJava('file.java')

jPath = fullfile(matlabroot, 'java', 'jarext');
cp = [fullfile(jPath, 'jogl-all.jar') pathsep fullfile(jPath, 'gluegen-rt.jar')];
cmd = ['javac -cp "' cp '" ' file];
status = system(cmd, '-echo');
if nargout
    varargout{1} = status;
end
