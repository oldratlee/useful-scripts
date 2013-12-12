#/bin/bash
# @Function
# show all console text color themes.

for style in 0 1 2 3 4 5 6 7; do
    for fg in 30 31 32 33 34 35 36 37; do
        for bg in 40 41 42 43 44 45 46 47; do
            combination="${style};${fg};${bg}"
            CTRL="\033[${combination}m"
            echo -e -n "${CTRL}"
            echo -e -n "${combination}"
            echo -e -n "\033[0m "
        done
        echo
    done
    echo
done

echo "output color text code sample: \033[1;36;41mSample Text\033[0m"
echo -n "above code effect: "
echo -e "\033[1;36;41mSample Text\033[0m"
