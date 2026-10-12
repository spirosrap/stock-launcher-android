package app.stocklauncher;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.Toast;

/** Opens Android's "Default home app" picker so the stock Pixel Launcher can be chosen in one tap. */
public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String[] actions = {
            Settings.ACTION_HOME_SETTINGS,
            Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS,
        };
        boolean opened = false;
        for (String action : actions) {
            try {
                startActivity(new Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
                opened = true;
                break;
            } catch (ActivityNotFoundException ignored) {
            }
        }
        if (opened) {
            Toast.makeText(this, R.string.hint, Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(this, R.string.failed, Toast.LENGTH_LONG).show();
        }
        finish();
    }
}
