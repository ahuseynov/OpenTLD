function [output] = process(filename, i, bb)
	if i==1
        init_workspace; 
    end
    output = run(filename, i, bb);
end

