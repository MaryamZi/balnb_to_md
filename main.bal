import ballerina/io;

const BAL_NOTEBOOK_EXT = ".balnotebook";
const MD_EXT = ".md";

const MARKDOWN = "markdown";

type NotebookEntry record {|
    string language;
    string value;
    json...;
|};

# Converts a Ballerina notebook file to MD format and writes it at the target path.
# 
# ```ballerina
# check balnb_to_md:convertToMd("./resources/myfile.balnotebook");
# check balnb_to_md:convertToMd("./resources/myfile.balnotebook", "/resources/converted.md");
# ```
# 
# + nbPath - The path of the input notebook file
# + targetPath - The path of the target MD file. If not specified, defaults to the name of the input file.
# + return - returns an error if the conversion fails
public function convertToMd(string nbPath, string? targetPath = ()) returns error? {
    if !nbPath.endsWith(BAL_NOTEBOOK_EXT) {
        return error("Expected a Ballerina Notebook with the '.balnotebook' extension");
    }

    json jsonContent = check io:fileReadJson(nbPath);
    NotebookEntry[] nbEntries = check jsonContent.cloneWithType();

    string[] content = [];

    foreach NotebookEntry entry in nbEntries {
        string language = entry.language;
        if language == MARKDOWN {
            content.push(entry.value, "\n");
            continue;
        }

        string value = entry.value;
        string backTickString = getBackTickString(value);
        content.push(string `${backTickString}${language}`, value, backTickString, "\n");
    }

    return io:fileWriteLines(targetPath ?: getOutputFilePath(nbPath), content);
}

function getBackTickString(string content) returns string {
    string s1 = "```";
    string s2 = "````";  

    while true {
        if !content.includes(s1) {
            return s1;
        }

        if !content.includes(s2) {
            return s2;
        }

        s1 += "`";
        s2 += "`";   
    }
}

function getOutputFilePath(string inputFilePath) returns string =>
    inputFilePath.substring(0, <int> inputFilePath.lastIndexOf(BAL_NOTEBOOK_EXT)) + MD_EXT;