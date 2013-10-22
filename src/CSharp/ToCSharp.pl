use strict;
use warnings;

my $Keyword = "(?:ifdef|endif|return|new|throw|class|interface|extends|implements|public|private|protected|static|final|function|instanceof|else|var)";
my $Sym  = "(?:(?!$Keyword\\b)\\b(?!\\d)\\w+\\b)";
my $Type = "(?:$Sym(?:<.*?>)?(?:\\[\\s*\\d*\\s*\\])*)";
my $Attr = "(?:\\b(?:public|private|protected|static|final)\\b\\s*)";

my $Grammar = "GreenTeaGrammar";

my $src = join '', <STDIN>;

my @StringLiterals;
my @Comments;

sub ProtectString{
	my $n = @StringLiterals;
	my $text = $_[0];
	$StringLiterals[$n] = $text;
	return "#STR$n#"
}

sub ProtectComment{
	my $n = @Comments;
	my $text = $_[0];
	$Comments[$n] = $text;
	return "#COMMENT$n#"
}

sub fixup {
	# "\\n" => "\n"
	my $text = $_[0];
	if(length($text) == 2) {
		my @list = split(//, $text);
		if($list[0] eq "\\") {
			if($list[1] eq "t") {
				return "\t";
			}
			if($list[1] eq "n") {
				return "\n";
			}
			if($list[1] eq "\\") {
				return "\\";
			}
		}
	}
	return $text;
}

# Delegates.
$src =~ s/Function(?:A|B|C)\(this, "(.+?)"\)/$Grammar\["$1"\]/g;

$src =~ s/delegate/\@delegate/g;

# Protect String literal
$src =~ s/(".*?")/&ProtectString($1)/ge;

# $src =~ s/};/}/g;

sub GreenTeaConstsSection{
	my $text = $_[0];
	return $text;
}

sub GreenTeaUtilsSection{
	my $text = $_[0];
	return $text;
}

sub UnQuote {
	my $text = $_[0];
}


#$src =~ s/interface GreenTeaConsts {(.*?)^}/GreenTeaConstsSection($1)/ems;
#$src =~ s/class GreenTeaUtils(.*?)^}/GreenTeaUtilsSection($1)/ems;

$src =~ s/interface/class/g;

# Comments
$src =~ s/^\s*\/\/[#\s]*ifdef\s+JAVA.*?VAJA//gms;

$src =~ s|/\*GreenTeaConst Begin\*/|public class GreenTeaConsts {|g;
$src =~ s|/\*GreenTeaConst End\*/|}|g;
$src =~ s|/\*GreenTeaUtils Begin\*/|public class GreenTeaUtils: GreenTeaConsts {|g;
$src =~ s|/\*GreenTeaUtils End\*/|}|g;

$src =~ s/(\/\/.*?)$/&ProtectComment($1)/gems;
# Array literals.
#$src =~ s/\/\*\s*BeginArray\s*\*\/{/{/g;
#$src =~ s/\/\*\s*EndArray\s*\*\/}/};/g;
# Protect Comments
$src =~ s/(\/\*.*?\*\/)/&ProtectComment($1)/gmse;

# Constants. public final static int N = 0; => var N: int = 0;
#$src =~ s/(?:$Attr*) ($Type)\s+($Sym)((?:\[\s*\d*\s*\])?)/$2: $1$3/g;

# Types
# $src =~ s/(?!")\b(?:char|int|long|float|double|Charactor|Integer|Long|Float|Double)\b(?!")/number/g;
# $src =~ s/\.(?:int|long|float|double|)Value\(\)//g;
$src =~ s/(?!")\bInteger\b/int/g;
$src =~ s/(?!")\bString\b/string/g;
$src =~ s/(?!")\bboolean\b/bool/g;
$src =~ s/(?!")\bObject\b/object/g;
$src =~ s/\bArrayList\b/List/g;
$src =~ s/\bType\b/\@Type/g;
$src =~ s/Class\<\?\>/Type/g;
$src =~ s/GtMap/LibGreenTea.GtMap/g;

# $src =~ s/\bGtMap\b/List/g;
# $src =~ s/\bnew\s+Array<.*?>\s*\(Arrays.asList\((.*?)\)\)/$1/g;
# $src =~ s/\bArrays.asList\b//g;
# $src =~ s/\.toArray\(\)//g;
$src =~ s/\b(\d+)L\b/$1/g;
$src =~ s/([a-zA-Z]*?)\.class/typeof($1)/g;
$src =~ s/typeof\(Void\)/typeof(void)/g;
$src =~ s/typeof\(Long\)/typeof(long)/g;

# $src =~ s/'(\\.)'/ord(fixup($1)) . '\/*' . $1 . '*\/'/eg;
# $src =~ s/'(.)'/ord($1) . '\/*' . $1 . '*\/'/eg;
# $src =~ s/('..')/($1.charCodeAt(0))/g;

$src =~ s/\bfinal\b/\/*final*\//g;
# $src =~ s/\bprotected\b//g;
$src =~ s/\@Override\s*/override /g;
$src =~ s/\@Deprecated\s*//g;
# $src =~ s/\bextends GreenTeaUtils\s*//g;
# $src =~ s/\bpublic interface\s*/interface /g;
# $src =~ s/\bGreenTeaUtils\.//g;
$src =~ s/\binstanceof\b/is/g;
$src =~ s/lastIndexOf/LastIndexOf/g;
$src =~ s/substring/Substring/g;
$src =~ s/\.getClass/.GetType/g;
$src =~ s/\.endsWith/.EndsWith/g;
$src =~ s/\.indexOf/.IndexOf/g;
$src =~ s/\.set/.Insert/g;
#$src =~ s/\b[a-zA-Z]*Exception/Exception/g;
$src =~ s/System.err.println\((.*)\)/Console.Error.WriteLine($1)/g;
$src =~ s/e\.printStackTrace\(\);/Console.WriteLine(System.Environment.StackTrace);/g;
$src =~ s/e\.GetStackTrace\(\)/System.Environment.StackTrace/g;
$src =~ s/SoftwareFaultException/Exception/g;
$src =~ s/getCanonicalName\(\)/FullName/g;
$src =~ s/getSimpleName\(\)/Name/g;



# $src =~ s/\binstanceof\s+string\b/instanceof String/g;
# $src =~ s/\binstanceof\s+number\b/instanceof Number/g;
# $src =~ s/\b([a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*) instanceof String/(typeof $1 == 'string' || $1 instanceof String)/g;

# $src =~ s/number.class/Number/g;
# $src =~ s/string.class/String/g;
# $src =~ s/Boolean.class/Boolean/g;
# $src =~ s/Object.class/Object/g;
# $src =~ s/Void.class/null/g;

# $src =~ s/\bpublic class\b/class/g;

$src =~ s/\bsize\(\)/Count()/g;
$src =~ s/length(\(\))?/Length/g;
$src =~ s/\bSystem\.out\.println/Console.WriteLine/g;
$src =~ s/\badd\(/Add(/g;
$src =~ s/\.get\((.*?)\)/[$1]/g;

$src =~ s/\bmain\b/Main/g;
$src =~ s/\bequals\b/Equals/g;
$src =~ s/\btoString\b/ToString/g;
$src =~ s/\bstartsWith\b/StartsWith/g;

$src =~ s/\b\sextends\b|\b\simplements\b/:/g;
$src =~ s/\boperator\b/\@operator/g;

$src =~ s/{\n\s*super\((.*?)\);/:base($1){/g;
$src =~ s/super/base/g;

# argument

$src =~ s/($Type)\s([a-zA-Z]+)\[\]/$1\[\] $2/g;

#method
$src =~ s/\.trim/.Trim/g;
$src =~ s/\.replace/.Replace/g;
$src =~ s/\.clear/.Clear/g;
$src =~ s/\(Arrays.asList\((this.Types)\)\)/($1)/g;

# Delegates.
# $src =~ s/(?!\.)\b((?:Parse|Type)(?:Unary|Binary|Const|Block))\b(?!\()/$Grammar\["$1"\]/g;
# $src =~ s/\bGtDelegate(?:Common|Token|Match|Type)\b/any/g;
# $src =~ s/$Grammar\.$Grammar/$Grammar/g;

# For debug
#$src =~ s/(LibGreenTea\.)?DebugP\(/console.log("DEBUG: " + /g;
#$src =~ s/LibGreenTea\.println\(/console.log(/g;
#src =~ s/function console.log\("DEBUG: " \+ /function DebugP(/g;

my $n = @Comments;
my $i = 0;
while($i < $n){
	$src =~ s/#COMMENT$i#/$Comments[$i]/;
	$i = $i + 1;
}

$n = @StringLiterals;
$i = 0;
while($i < $n){
	$src =~ s/#STR$i#/$StringLiterals[$i]/;
	$i = $i + 1;
}



###TODO
$src =~ s/\b(public\s)?(\/\*.+\*\/\s)?class\b/public class/g;
$src =~ s/\b(public\s)?(\b$Sym\b\/\*constructor\*\/)/public $2/g;
$src =~ s/protected\spublic/protected/g;
#$src =~ s/(GtResolvedFunc UpdateFunc)/public $1/g;
#$src =~ s/(public\s)?(\b$Type\s$Sym\b)/public $2/g;


print <<'EOS';
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
EOS
print $src;
