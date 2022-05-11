import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

import 'bloc/bloc_actions.dart';
import 'bloc/person.dart';
import 'bloc/persons_bloc.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => PersonsBloc(),
        child: const MyHomePage(),
      ),
    );
  }
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url)) //* gives us a request
    .then((value) => value.close()) //* request becomes a response
    .then((value) => value.transform(utf8.decoder).join()) //* reponse becomes a string
    .then((value) => json.decode(value) as List<dynamic>) //* string becomes a list
    .then((value) => value.map((e) => Person.fromJson(e))); // * list becomes an iterable of person resulting a future

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, World!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    final foo = context
                        .read<PersonsBloc>()
                        .add(const LoadPersonsAction(url: persons1Url, loader: getPersons));
                  },
                  child: const Text('Load JSON #1'),
                ),
                TextButton(
                  onPressed: () {
                    final foo = context
                        .read<PersonsBloc>()
                        .add(const LoadPersonsAction(url: persons2Url, loader: getPersons));
                  },
                  child: const Text('Load JSON #2'),
                ),
              ],
            ),
            BlocBuilder<PersonsBloc, FetchResult?>(
              buildWhen: ((previous, current) {
                return previous?.persons != current?.persons;
              }),
              builder: ((context, fetchResult) {
                fetchResult?.log();
                final persons = fetchResult?.persons;
                if (persons == null) {
                  return const SizedBox();
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (context, index) {
                      final person = persons[index]!;
                      return ListTile(
                        title: Text(person.name),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}