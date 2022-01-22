{ writeShellApplication
, deno
, fd
}:
writeShellApplication {
  name = "flake-no-path";
  runtimeInputs = [
    deno
    fd
  ];
  text = ''
    if [[ $# -eq 0 ]]
    then
      fd --one-file-system flake.lock \
        | xargs deno run --allow-env --allow-read ${./main.ts}
    else
      exec deno run --allow-env --allow-read ${./main.ts} "$@"
    fi
  '';
}
