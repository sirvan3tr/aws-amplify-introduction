
AWS Amplify[@AmplifyFrameworkDocs2021] is a framework to rapidly create web and mobile applications (including APIs). It uses the rich AWS ecosystem to speed up development and deployment.

AWS Amplify includes an easy to use CLI, set of libraries for popular front-end libraries (e.g. react and vuejs), and UI components. Using AWS Amplify one can create **authentication**, **storage**, **API** (GraphQL and REST), **DataStore**, and much more.

# Authentication


# API GraphQL
GraphQL\footnote{graphql.org} is a query language for your API. It is often compared to the REST architecture. We won’t compare them here, but a simple Google search will provide you plenty of answers.

* Assuming you have done \cde{amplify init}, you can begin to add an API by doing \cde{amplify add api}. Following the instructions will hopefully get you to where you need to go.
* You will be able to update your API schema at:

\cde{/amplify/backend/api/gqls3/schema.graphql}.

* \cde{amplify push} will deploy your API to the AWS cloud services.
* Object types that are annotated with \model are top-level entities in the generated API. Objects annotated with \model are stored in Amazon DynamoDB and are capable of being protected via \auth, related to other objects via \cde{@connection}, and streamed into Amazon OpenSearch via \cde{@searchable}. You may also apply the \cde{@versioned} directive to instantly add a version field and conflict detection to a model type.
* \cde{createdOn} and \cde{updatedOn} fields are automatically created for your models.

\marginnote[-5cm]{
\textsc{Amplify GraphQL Data Types:}
\begin{itemize}
\itemsep0em 
\item ID
\item String
\item Int
\item Float
\item Boolean
\item AWSDate
\item AWSTime
\item AWSDateTime
\item AWSTimeStamp
\item AWSEmail
\item AWSJSON
\item AWSPhone
\item AWSURL
\item AWSIPAddress
\end{itemize}
}

# Relationships
\cde{@connection} enables you to specify relationships between models. 1-to-1, 1-to-many, and m-to-m are supported.

## One-to-one
\begin{figure}[h]
\caption{\cde{Project} has one \cde{Team} and we have \cde{teamID} as an identifier for the team that the project belongs to.}
\begin{lstlisting}
type Project @model {
  id: ID!
  name: String
  teamID: ID!
  team: Team @connection(fields: ["teamID"])
}

type Team @model {
  id: ID!
  name: String!
}
\end{lstlisting}
\end{figure}

## One-to-many
This needs a \cde{@key} item.

\begin{figure}[h]
\caption{\cde{Post} can have many \cde{Comment}s.}
\begin{lstlisting}
type Post @model {
  id: ID!
  title: String!
  comments: [Comment] @connection(keyName: "byPost", fields: ["id"])
}

type Comment @model
  @key(name: "byPost", fields: ["postID", "content"]) {
  id: ID!
  postID: ID!
  content: String!
}
\end{lstlisting}
\end{figure}

## Belongs to

\begin{figure}[h]
\caption{You can make a connection bi-directional by adding a many-to-one connection to types that already have a one-to-many connection. In this case you add a connection from Comment to Post since each comment belongs to a post:}
\begin{lstlisting}
type Post @model {
  id: ID!
  title: String!
  comments: [Comment] @connection(keyName: "byPost", fields: ["id"])
}

type Comment @model
  @key(name: "byPost", fields: ["postID", "content"]) {
  id: ID!
  postID: ID!
  content: String!
  post: Post @connection(fields: ["postID"])
}
\end{lstlisting}
\end{figure}

# Authorization
\marginnote{
\textsc{GraphQL Operation Types:}
\begin{itemize}
\itemsep0em 
\item \cde{CREATE}
\item \cde{DELETE}
\item \cde{GET}
\item \cde{LIST}
\item \cde{UPDATE}
\end{itemize}
}

Models annotated with \auth are protected by a set of authorization rules. When using the \auth directive on object type definitions that are also annotated with \model, all resolvers that return objects of that type will be protected. When using the \auth directive on a field definition, a resolver will be added to the field that authorize access based on attributes found in the parent type.

We can protect our models (think of them as database tables) at **model level**; this means that all the fields in that model will have the same protection. We can also protect individual fields at **field level authorisation**. We can use both methods at the same time. This level of protection is required as we demand different CRUD access from our users.

We authorise access with respect to users. We can abstract our users to the following types:

* \cde{owner}.  The individual that *owns* the record.
* \cde{groups}.  Static groups of users that have shared permission, e.g. admins.
* \cde{public}.  Anyone can access the API.
* \cde{private}.  The private authorization specifies that everyone will be allowed to access the API with a valid JWT token from the configured Cognito User Pool.

\begin{figure}[h]
\begin{lstlisting}
type Post @model
  @auth (
    rules: [
      # allow all authenticated users ability to create posts
      # allow owners ability to update and delete their posts
      { allow: owner },

      # allow all authenticated users to read posts
      { allow: private, operations: [read] },

      # allow all guest users (not authenticated) to read posts
      { allow: public, operations: [read] }
    ]
  ) {
  id: ID!
  title: String
  owner: String
}
\end{lstlisting}
\end{figure}


## Model Level Authorization
\begin{figure}[h]
\caption{In this schema, only the owner of the object has the authorization to perform read (getTodo and listTodos), update (updateTodo), and delete (deleteTodo) operations on the owner created object. This prevents the object from being updated or deleted by users other than the creator of the object.}
\begin{lstlisting}
type Post @model
  @auth(rules: [{ allow: owner }]) {
  id: ID!
  title: String!
}
\end{lstlisting}
\end{figure}


\begin{figure}[h]
\caption[][1.2cm]{This \auth rule says: only the owner can delete, and update this model. Others can therefore read (get and list) and create.}
\begin{lstlisting}
type Todo @model
  @auth(rules: [{ allow: owner, operations: [create, delete, update] }]) {
  id: ID!
  updatedAt: AWSDateTime!
  content: String!
}
\end{lstlisting}
\end{figure}

## Field Level Authorization
\begin{marginlisting}
type User @model {
  id: ID!
  username: String
  ssn: String @auth(rules: [
      { allow: owner,
      ownerField: "username" }
    ])
}
\end{marginlisting}

\marginnote{
You might want to have a user model where some fields, like username, are a part of the public profile and the ssn field is visible to owners.
}

* You may dictate field level authorisation. E.g. you may only want an admin to `update` a certain field.

\begin{figure}
\begin{lstlisting}
type Employee @model {
  id: ID!
  email: String
  username: String

  # Owners & members of the "Admin" group may read employee salaries.
  # Only members of the "Admin" group may create an employee with a salary
  # or update a salary.
  salary: String
    @auth(rules: [
      { allow: owner, ownerField: "username", operations: [read] },
      { allow: groups, groups: ["Admin"], operations: [create, update, read] }
    ])
}
\end{lstlisting}
\end{figure}


