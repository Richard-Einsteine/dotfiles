function vidtitle
    # Dependency Check
    set -l deps mkvpropedit exiftool fd
    for d in $deps
        if not type -q $d
            notify-send \
                --urgency critical \
                --icon dialog-error \
                --hint=string:desktop-entry:org.kde.dolphin \
                "System Error" "Required command '$d' not found."
            return 1
        end
    end

    for target in $argv
        if test -d "$target"
            for file in (fd -t f . "$target")
                __process_file "$file"
            end

        else if test -f "$target"
            __process_file "$target"

        else
            notify-send \
                --urgency=critical \
                --icon=dialog-error \
                --hint=string:desktop-entry:org.kde.dolphin \
                "Error " "'$target' is not a valid target."
            continue
        end
    end

    notify-send \
        --urgency=normal \
        --expire-time=3000 \
        --icon=dialog-information \
        --hint=string:desktop-entry:org.kde.dolphin \
        "Vid Title" "Process finished."
end

# Internal helper function
function __process_file
    set -l file "$argv[1]"

    switch (string lower (path extension "$file"))
        case .mkv
            mkvpropedit "$file" -e info -s title=(path basename -E "$file")
        case .mp4 .mov .m4v
            exiftool -overwrite_original -Title=(path basename -E "$file") "$file"
            # mp4edit_title "$file" &
        case *
            # Ignore other files
            return 0
    end
end
