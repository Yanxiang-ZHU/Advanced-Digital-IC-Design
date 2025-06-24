def commit_callback(commit):
    old_email = b"m18652829333@163.com"
    new_name = b"Yanxiang-ZHU"
    new_email = b"zhu.yx.0073@gmail.com"

    if commit.author_email == old_email:
        commit.author_name = new_name
        commit.author_email = new_email
    if commit.committer_email == old_email:
        commit.committer_name = new_name
        commit.committer_email = new_email