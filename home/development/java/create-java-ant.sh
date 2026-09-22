#!/usr/bin/env bash

set -e

echo "╭──────────────────────────────╮"
echo "│      Java + Ant Project      │"
echo "╰──────────────────────────────╯"
echo

read -rp "¿Crear el proyecto en el directorio actual? [Y/n]: " CURRENT

if [[ -z "$CURRENT" || "$CURRENT" =~ ^[Yy]$ ]]; then
    BASE_DIR="$PWD"
else
    read -rp "Ruta donde crear el proyecto: " BASE_DIR
    BASE_DIR="${BASE_DIR/#\~/$HOME}"

    if [[ ! -d "$BASE_DIR" ]]; then
        echo "La ruta no existe."
        exit 1
    fi
fi

read -rp "Nombre del proyecto: " PROJECT_NAME

if [[ -z "$PROJECT_NAME" ]]; then
    echo "El nombre del proyecto no puede estar vacío."
    exit 1
fi

PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"

if [[ -e "$PROJECT_DIR" ]]; then
    echo
    echo "Ya existe: $PROJECT_DIR"
    exit 1
fi

echo
echo "Creando proyecto..."
echo

mkdir -p "$PROJECT_DIR/src"
mkdir -p "$PROJECT_DIR/build"
mkdir -p "$PROJECT_DIR/dist"

cat > "$PROJECT_DIR/src/Main.java" <<EOF
public class Main {

    public static void main(String[] args) {
        System.out.println("Hola desde $PROJECT_NAME");
    }
}
EOF

cat > "$PROJECT_DIR/build.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>

<project name="$PROJECT_NAME" default="run" basedir=".">

    <!-- Directorios -->
    <property name="src.dir" value="src"/>
    <property name="build.dir" value="build"/>
    <property name="classes.dir" value="\${build.dir}/classes"/>
    <property name="dist.dir" value="dist"/>

    <!-- JAR -->
    <property name="jar.name" value="$PROJECT_NAME.jar"/>

    <!-- Inicialización -->
    <target name="init">
        <mkdir dir="\${classes.dir}"/>
        <mkdir dir="\${dist.dir}"/>
    </target>

    <!-- Limpiar -->
    <target name="clean">
        <delete dir="\${build.dir}"/>
        <delete dir="\${dist.dir}"/>
    </target>

    <!-- Compilar -->
    <target name="compile" depends="init">
        <javac
            srcdir="\${src.dir}"
            destdir="\${classes.dir}"
            includeantruntime="false"
            encoding="UTF-8"
        />
    </target>

    <!-- Ejecutar -->
    <target name="run" depends="compile">
        <java
            classname="Main"
            fork="true"
            failonerror="true"
        >
            <classpath>
                <pathelement location="\${classes.dir}"/>
            </classpath>
        </java>
    </target>

    <!-- Crear JAR -->
    <target name="jar" depends="compile">
        <jar
            destfile="\${dist.dir}/\${jar.name}"
            basedir="\${classes.dir}"
        >
            <manifest>
                <attribute
                    name="Main-Class"
                    value="Main"
                />
            </manifest>
        </jar>
    </target>

    <!-- Limpiar + compilar + JAR -->
    <target name="build" depends="clean,jar"/>

</project>
EOF

echo "✓ Proyecto creado:"
echo
echo "  $PROJECT_DIR"
echo
echo "Estructura:"
echo
echo "  $PROJECT_NAME/"
echo "  ├── build.xml"
echo "  ├── src/"
echo "  │   └── Main.java"
echo "  ├── build/"
echo "  └── dist/"
echo
echo "Para comenzar:"
echo
echo "  cd \"$PROJECT_DIR\""
echo "  ant run"
echo
