-- | Representation of parsed Haskell source, following Part I of
-- [Haskell98 report](https://www.haskell.org/onlinereport/index.html). It does
-- not yet resolve things like name scoping - these are left for later
-- representations.
--
-- This module is meant to be imported qualified, e.g. like
--
-- > import Language.Hask.Parsed.AST qualified as Parsed
module Language.Hask.Parsed.AST
  ( -- * Modules
    Module (..)
  , -- * Imports/exports
    Export (..)
  , ImportDeclaration (..)
  , Import (..)
  , TypeImportList (..)
  , -- * Declarations
    Declaration (..)
  , DatatypeBody (..)
  , Deriving
  , NewtypeConstructor (..)
  , DataConstructor (..)
  , Strictness
  , Class (..)
  , Instance (..)
  , Binding (..)
  , Associativity (..)
  , ValueBinding (..)
  , -- * Expressions and patterns
    Expression
  , Pattern
  , ValueUse (..)
  , Value (..)
  , Statement (..)
  , Qualifier (..)
  , -- * Types
    Type (..)
  , -- * Parsed names
    ModuleName (..)
  , Qualified (..)
  , VariableName (..)
  , ConstructorName (..)
  , Name (..)
    -- * Notes
    -- $ParsedTypeImportLists
    -- $TypesInDeclarationHeads
    -- $BindingsInInstances
  ) where

import Data.Kind qualified as Kind
import Data.List.NonEmpty (NonEmpty (..))
import Data.Text (Text)
import Numeric.Natural

-------------------------------------------------------------------------------
-- | Parsed Haskell module.
--
-- > module $moduleId ($moduleExports) where
-- >
-- > $moduleImports
-- >
-- > $moduleDeclarations
data Module = Module{
    moduleName         :: ModuleName
  , moduleExports      :: [Export]
  , moduleImports      :: [ImportDeclaration]
  , moduleDeclarations :: [Declaration]
  } deriving stock Show

-- | Parsed export from current module.
data Export
  = VariableExport (Qualified VariableName)
    -- ^ Export of a simple variable.
  | TypeExport (Qualified ConstructorName) (Maybe TypeImportList)
    -- ^ Export of a type.
    --
    -- > $1
    --
    -- or
    --
    -- > $1 ($2)
    --
    -- See [Parsed type import/export lists](#ParsedTypeImportLists).
  | ModuleExport ModuleName
    -- ^ Export of a module.
    --
    -- > module $1
  deriving stock Show

-- | Parsed import declaration.
--
-- > import $importQualified $importName $importAlias $importHiding ($importList)
data ImportDeclaration = ImportDeclaration{
    importQualified :: Bool             -- ^ Presence of @qualified@ keyword.
  , importName      :: ModuleName
  , importAlias     :: Maybe ModuleName -- ^ Presense of @as $_@ syntax.
  , importHiding    :: Bool             -- ^ Presence of @hiding@ keyword.
  , importList      :: [Import]
  } deriving stock Show

-- | Parsed import.
data Import
  = VariableImport VariableName
    -- ^ Import of a simple variable.
  | TypeImport ConstructorName (Maybe TypeImportList)
    -- ^ Import of a type.
    --
    -- > $1
    --
    -- or
    --
    -- > $1 ($2)
    --
    -- See [Parsed type import/export lists](#ParsedTypeImportLists).
  deriving stock Show

-- | Parsed import/export list of a type. You may be interested in
-- [Parsed type import/export lists](#ParsedTypeImportLists).
data TypeImportList
  = TypeImportAll
    -- ^ Import/export of all members in scope.
    --
    -- > (..)
  | TypeImportList [Either VariableName ConstructorName]
    -- ^ Import/export of explicitly named members.
    --
    -- > ($1)
  deriving stock Show

-- $ParsedTypeImportLists
-- == Parsed type import/export lists #ParsedTypeImportLists#
-- 'TypeImportList's contain both class and datatype imports/exports, because
-- we can't yet distinguish those properly - that's up to the renamer.

-------------------------------------------------------------------------------
-- | Parsed top-level declaration.
data Declaration
  = TypeSynonym Type Type
    -- ^ Type synonym declaration.
    --
    -- > type $1 = $2
  | Datatype Type DatatypeBody (Maybe Deriving)
    -- ^ Datatype declaration.
    --
    -- > data $1 = $_ | ... $3
    --
    -- or
    --
    -- > newtype $1 = $2 $3
    --
    -- See [Types in declaration heads](#TypesInDeclarationHeads).
  | ClassDeclaration Class
  | InstanceDeclaration Instance
  | Defaults [Type]
    -- ^ "default" declaration.
    --
    -- > default ($1)
  | Binding Binding
  deriving stock Show

-- | Parsed datatype body.
data DatatypeBody = Newtype NewtypeConstructor | Data [DataConstructor]
  deriving stock Show

-- | Parsed deriving clause.
--
-- > deriving $_
--
-- or
--
-- > deriving ($_, ...)
type Deriving = Either (Qualified ConstructorName) [Qualified ConstructorName]

-- | Parsed "newtype" constructor.
--
-- > $newtypeConstructorName { $newtypeConstructorLabel :: $newtypeConstructorField }
data NewtypeConstructor = NewtypeConstructor{
    newtypeConstructorName  :: ConstructorName
  , newtypeConstructorLabel :: Maybe VariableName
  , newtypeConstructorField :: Type
  } deriving stock Show

-- | Parsed "data" constructor.
--
-- > $dataConstructorName $dataConstructorFields
data DataConstructor = DataConstructor{
    dataConstructorName   :: ConstructorName
  , dataConstructorFields :: Either [Type] [(VariableName, Strictness, Type)]
    -- ^ "data" constructor fields, possibly named.
    --
    -- > $_ ...
    --
    -- or
    --
    -- > { $_ :: $_, ... }
  } deriving stock Show

-- | Parsed presence of strictness flag ("bang" @!@).
type Strictness = Bool

-- | Parsed class declaration.
--
-- > class $classType where $classDeclarations
data Class = Class{
    classType         :: Type
    -- ^ See [Types in declaration heads](#TypesInDeclarationHeads).
  , classDeclarations :: [Binding]
  } deriving stock Show

-- | Parsed instance declaration.
--
-- > instance $instanceType where $instanceDefinitions
data Instance = Instance{
    instanceType        :: Type
    -- ^ See [Types in declaration heads](#TypesInDeclarationHeads).
  , instanceDeclarations :: [Binding]
    -- ^ See [Bindings in instances](#BindingsInInstances).
  } deriving stock Show

-- $BindingsInInstances
-- == Bindings in instances #BindingsInInstances#
-- We parse 'Binding's inside of instance declarations, which means that we can
-- later fail with nicer error, plus we pave a way for possible future support
-- for @InstanceSigs@ extension, which could provide value as a sort of
-- "typechecked documentation".

-- | Parsed bindings-related declaration.
data Binding
  = Signature [VariableName] Type
    -- ^ Type signature for one or more bindings.
    --
    -- > $_, ... :: $2
  | Fixity Associativity Natural [VariableName]
    -- ^ Fixity declaration.
    --
    -- > $1 $2 $3
  | ValueBindingDeclaration ValueBinding -- TODO: better name?
  deriving stock Show

-- | Parsed associativity in fixity declaration.
--
-- @infix@ or @infixl@ or @infixr@
data Associativity = Infix | Infixl | Infixr deriving stock Show

-- | Parsed value binding declaration.
--
-- > $bindingHead = $bindingBody where $bindingBindings
data ValueBinding = ValueBinding{
    bindingHead     :: Either Pattern (VariableName, NonEmpty Pattern)
    -- ^ Head of either pattern or function binding.
  , bindingBody     :: Expression
  , bindingBindings :: Maybe [Binding]
    -- ^ Optional (and possibly empty) @where@ clause.
  } deriving stock Show

-------------------------------------------------------------------------------
-- TODO: how do we want to represent float literals?

-- | Parsed expression. See 'Value'.
type Expression = Value 'AsExpression

-- | Parsed pattern. See 'Value'.
type Pattern = Value 'AsPattern

-- | Data kind restricting use of 'Value' constructors to expressions or
-- patterns.
data {-kind-} ValueUse = AsExpression | AsPattern

-- | Parsed value-level construct - this can be either expression or pattern,
-- where each has some specific constructors not found in the other, restricted
-- by 'ValueUse'. Those not restricted can appear in both.
data Value :: ValueUse -> Kind.Type where
  -- | Expression with type annotation.
  --
  -- > $1 :: $2
  TypeAnnotation
    :: Expression -> Type -> Expression
  -- | Infix expression.
  --
  -- > $1 `$2` $3
  --
  -- in case of prefix name, or
  --
  -- > $1 $2 $3
  --
  -- in case of operator.
  InfixExpression
    :: Expression -> Name -> Expression -> Expression
  -- | Left section.
  --
  -- > ($1 `$2`)
  --
  -- in case of prefix name, or
  --
  -- > ($1 $2)
  --
  -- in case of operator.
  LeftSection
    :: Expression -> Name -> Expression
  -- | Right section.
  --
  -- > (`$1` $2)
  --
  -- in case of prefix name, or
  --
  -- > ($1 $2)
  --
  -- in case of operator.
  RightSection
    :: Name -> Expression -> Expression
  -- | Prefix negation.
  --
  -- > - $1
  Negation
    :: Expression -> Expression
  -- | Lambda abstraction.
  --
  -- > \ $1 -> $2
  Lambda
    :: NonEmpty Pattern -> Expression -> Expression
  -- | "let-in" expression binding group of values in scope of an expression.
  --
  -- > let $1 in $2
  LetIn
    :: [Binding] -> Expression -> Expression
  -- | "if-then-else" expression.
  --
  -- > if $1 then $2 else $3
  IfThenElse
    :: Expression -> Expression -> Expression -> Expression
  -- | "case" expression.
  --
  -- > case $1 of $_ -> $_; ...
  CaseOf
    :: Expression -> [(Pattern, Expression)] -> Expression
  -- | "do" block.
  --
  -- > do $_; ...; $2
  Do
    :: [Statement] -> Expression -> Expression
  -- | Function application.
  --
  -- > $1 $2
  Application
    :: Expression -> Expression -> Expression
  -- | Variable or constructor appearing as expression.
  NameExpression
    :: Name -> Expression
  -- | Arithmetic sequence.
  --
  -- > [ $1 .. ]
  --
  -- or
  --
  -- > [ $1 .. $3 ]
  --
  -- or
  --
  -- > [ $1, $2 .. $3 ]
  Sequence -- TODO: some better approach?
    :: Expression
    -> Maybe (Either Expression (Expression, Expression))
    -> Expression
  -- | List comprehension.
  --
  -- > [ $1 | $2 ]
  Comprehension
    :: Expression -> NonEmpty Qualifier -> Expression
  -- | Record construction.
  --
  -- > $1 { $_ = $_, ... }
  RecordConstruction
    :: ConstructorName -> [(VariableName, Expression)] -> Expression
  -- | Record update.
  --
  -- > $1 { $_ = $_, ... }
  RecordUpdate
    :: Expression -> NonEmpty (VariableName, Expression) -> Expression

  -- | Unit constructor.
  --
  -- > ()
  Unit
    :: Value any
  -- | List literal.
  --
  -- > [$_, ...]
  List
    :: [Value any] -> Value any
  -- | Tuple literal.
  --
  -- > ($_, $_, ...)
  Tuple -- TODO: some better approach?
    :: (Value any, NonEmpty (Value any)) -> Value any
  Integer
    :: Integer -> Value any
  Float
    :: Rational -> Value any
  -- | Character literal.
  --
  -- > '$1'
  Char
    :: Char -> Value any
  -- | String literal.
  --
  -- > "$1"
  String
    :: Text -> Value any
  -- | Wildcard pattern / hole expression.
  --
  -- > _
  Wildcard
    :: Value any
  -- | Parenthesized value.
  --
  -- > ($1)
  Parens
    :: Value any -> Value any

  -- | "n+k" pattern.
  --
  -- > $1 + $2
  Successor
    :: VariableName -> Integer -> Pattern
  -- | Negative literal pattern.
  --
  -- > - $1
  NegativeLiteral
    :: Either Natural Rational -> Pattern
  -- | "as" pattern, binding variable name to same value as following pattern.
  --
  -- > $1 @ $2
  As
    :: VariableName -> Pattern -> Pattern
  -- | Constructor pattern.
  --
  -- > ($_ `$2` $_) $_ ...
  --
  -- or
  --
  -- > ($_ $2 $_) $_ ...
  --
  -- or
  --
  -- > $2 $_ ...
  --
  -- or
  --
  -- > $2 { $_ = $_, ... }
  ConstructorPattern -- TODO: some better approach?
    :: Bool
    -- ^ Is constructor name positioned as infix?
    -> ConstructorName
    -> Either [Pattern] [(VariableName, Pattern)]
    -- ^ Pattern arguments or record syntax.
    -> Pattern
  -- | Irrefutable pattern.
  --
  -- > ~ $1
  Irrefutable
    :: Pattern -> Pattern

deriving stock instance Show (Value any)

-- | Parsed statement in @do@ block.
data Statement
  = Then Expression
    -- ^ Simple expression used as a statement.
  | Bind Pattern Expression
    -- ^ Binding of expression result to some pattern.
    --
    -- > $1 <- $2
  | Let [Binding]
    -- ^ "let" statement binding some values.
    --
    -- > let $_ = $_, ...
  | EmptyStatement
    -- ^ Empty statement - e.g. redundant @;@.
  deriving stock Show

-- | Parsed qualifier in list comprehension.
data Qualifier
  = Generator Pattern Expression
    -- ^ Generator, binding pattern to some list expression.
    --
    -- > $1 <- $2
  | QualifierLet [Binding]
    -- ^ "let" qualifier binding some values.
    --
    -- let $_ = $_, ...
  | Guard Expression
    -- ^ Boolean expression used as a guard.
  deriving stock Show

-------------------------------------------------------------------------------
-- | Parsed type.
data Type
  = Constrainted Type Type
    -- ^ Constrained type.
    --
    -- > $1 => $2
  | FunctionType Type Type
    -- ^ Function type.
    --
    -- > $1 -> $2
  | TypeApplication Type Type
    -- ^ Type application.
    --
    -- > $1 $2
  | NameType Name
    -- ^ Type variable or type constructor.
  | TupleType (Type, NonEmpty Type)
    -- ^ Tuple type.
    --
    -- > ($_, $_, ...)
  | ListType Type
    -- ^ List type.
    --
    -- > [$1]
  | TypeParens Type
    -- ^ Parenthesized type.
    --
    -- > ($1)
  | ListTypeConstructor
    -- ^ List type constructor.
    --
    -- > []
  | FunctionTypeConstructor
    -- ^ Function type constructor.
    --
    -- > (->)
  | TupleTypeConstructor Natural
    -- ^ Tuple type constructor, described by it's size. Unit constructor is
    -- case of size 0.
    -- __Invariant: size of tuple is never 1.__
    --
    -- > ()
    --
    -- or
    --
    -- > (,...)
  deriving stock Show

-- $TypesInDeclarationHeads
-- == Types in declaration heads #TypesInDeclarationHeads#
-- Instead of parsing limited subset of types in declaration heads, we parse
-- all possible types - for simplicity, but mainly to be able to provide better
-- errors later, talking in context of types instead of parts that don't fit.

-------------------------------------------------------------------------------
-- | Parsed module name.
newtype ModuleName = ModuleName{ moduleNameParts :: NonEmpty Text }
  deriving stock Show

-- | Some value enriched with parsed module name - e.g. qualified names in
-- expressions.
data Qualified a = Qualified{
    qualifiedModule :: ModuleName
  , qualifiedValue  :: a
  } deriving stock (Functor, Show)

-- | Parsed variable name.
newtype VariableName = VariableName{ variableNameText :: Text }
  deriving stock Show

-- | Parsed constructor name.
data ConstructorName = ConstructorName{ constructorNameText :: Text }
  deriving stock Show

-- | Parsed, qualified name - that is, either (type) variable or (type)
-- constructor name.
data Name
  = Variable (Qualified VariableName)
  | Constructor (Qualified ConstructorName)
  deriving stock Show
